/**
 * VideoFind AI - Search Form Controller
 * Matches screenshot layout: upload dropzone, preview card, tag pills, platforms, and search action.
 */

import { api } from './api.js';

class SearchController {
  constructor() {
    this.currentReference = null;
    this.keywords = ['beauty', 'lipstick', 'makeup', 'cosmetics', 'luxury'];
    this.selectedPlatforms = ['YouTube', 'Facebook'];
    this.customQuery = '';

    // DOM Elements
    this.dropzone = document.getElementById('upload-dropzone-box');
    this.fileInput = document.getElementById('reference-video-file');
    this.previewCard = document.getElementById('reference-preview-card');
    this.previewThumb = document.getElementById('preview-thumb-img');
    this.previewFilename = document.getElementById('preview-filename-text');
    this.previewFilesize = document.getElementById('preview-filesize-text');

    this.keywordsContainer = document.getElementById('keywords-container');
    this.keywordInput = document.getElementById('keyword-text-input');
    this.btnAddKeyword = document.getElementById('btn-add-keyword');

    this.descriptionInput = document.getElementById('search-description');
    this.charCounter = document.getElementById('description-char-counter');

    this.platformCards = document.querySelectorAll('.platform-select-card');
    this.advancedToggle = document.getElementById('advanced-search-toggle');
    this.advancedContent = document.getElementById('advanced-search-content');
    this.advancedChevron = document.getElementById('advanced-chevron');
    this.sortSelect = document.getElementById('sort-select-input');

    this.btnFindSimilar = document.getElementById('btn-find-similar');

    this.init();
  }

  init() {
    if (!this.btnFindSimilar) return;

    // File Dropzone
    if (this.dropzone && this.fileInput) {
      this.dropzone.addEventListener('click', () => this.fileInput.click());
      this.dropzone.addEventListener('dragover', (e) => {
        e.preventDefault();
        this.dropzone.classList.add('dragover');
      });
      this.dropzone.addEventListener('dragleave', () => this.dropzone.classList.remove('dragover'));
      this.dropzone.addEventListener('drop', (e) => {
        e.preventDefault();
        this.dropzone.classList.remove('dragover');
        if (e.dataTransfer.files && e.dataTransfer.files[0]) {
          this.handleFileUpload(e.dataTransfer.files[0]);
        }
      });

      this.fileInput.addEventListener('change', (e) => {
        if (e.target.files && e.target.files[0]) {
          this.handleFileUpload(e.target.files[0]);
        }
      });
    }

    // Keyword management
    if (this.keywordInput) {
      this.keywordInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ',') {
          e.preventDefault();
          this.addFromInput();
        } else if (e.key === 'Backspace' && !this.keywordInput.value && this.keywords.length > 0) {
          this.removeKeyword(this.keywords[this.keywords.length - 1]);
        }
      });
    }

    if (this.btnAddKeyword) {
      this.btnAddKeyword.addEventListener('click', () => this.addFromInput());
    }

    // Remove tag click delegation
    if (this.keywordsContainer) {
      this.keywordsContainer.addEventListener('click', (e) => {
        const removeBtn = e.target.closest('.remove-tag');
        if (!removeBtn) return;
        const tag = removeBtn.dataset.tag;
        if (tag) this.removeKeyword(tag);
      });
    }

    // Description counter
    if (this.descriptionInput && this.charCounter) {
      this.descriptionInput.addEventListener('input', () => {
        this.charCounter.textContent = `${this.descriptionInput.value.length}/500`;
        this.syncGlobalState();
      });
    }

    // Platforms toggle
    this.platformCards.forEach(card => {
      card.addEventListener('click', () => {
        card.classList.toggle('selected');
        this.updateSelectedPlatforms();
      });
    });

    // Advanced search accordion
    if (this.advancedToggle && this.advancedContent) {
      this.advancedToggle.addEventListener('click', () => {
        const isOpen = this.advancedContent.classList.toggle('open');
        if (this.advancedChevron) {
          this.advancedChevron.style.transform = isOpen ? 'rotate(180deg)' : 'rotate(0deg)';
        }
      });
    }

    // Submit Find Similar Videos
    this.btnFindSimilar.addEventListener('click', () => this.executeSearch());

    // Initial sync
    this.renderKeywords();
    this.updateSelectedPlatforms();
  }

  addFromInput() {
    if (!this.keywordInput) return;
    const val = this.keywordInput.value.trim().replace(/^,|,$/g, '');
    if (val) {
      this.addKeyword(val);
      this.keywordInput.value = '';
    }
  }

  addKeyword(keyword) {
    const cleaned = keyword.trim().toLowerCase();
    if (!cleaned || this.keywords.includes(cleaned)) return;
    this.keywords.push(cleaned);
    this.renderKeywords();
    this.syncGlobalState();
  }

  addKeywords(list) {
    list.forEach(k => {
      const cleaned = k.trim().toLowerCase();
      if (cleaned && !this.keywords.includes(cleaned)) {
        this.keywords.push(cleaned);
      }
    });
    this.renderKeywords();
    this.syncGlobalState();
  }

  removeKeyword(keyword) {
    this.keywords = this.keywords.filter(k => k !== keyword);
    this.renderKeywords();
    this.syncGlobalState();
  }

  renderKeywords() {
    if (!this.keywordsContainer) return;
    const existingPills = this.keywordsContainer.querySelectorAll('.keyword-tag-pill');
    existingPills.forEach(p => p.remove());

    this.keywords.forEach(kw => {
      const pill = document.createElement('span');
      pill.className = 'keyword-tag-pill';
      pill.innerHTML = `${kw} <span class="remove-tag" data-tag="${kw}">&times;</span>`;
      this.keywordsContainer.insertBefore(pill, this.keywordInput);
    });
  }

  handleFileUpload(file) {
    const customTitle = file.name;
    const sizeMb = (file.size / (1024 * 1024)).toFixed(1) + ' MB';
    const objectUrl = URL.createObjectURL(file);

    if (this.previewFilename) this.previewFilename.textContent = customTitle;
    if (this.previewFilesize) this.previewFilesize.textContent = sizeMb;
    if (this.previewThumb) {
      this.previewThumb.src = 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=400&q=80';
    }

    this.currentReference = {
      id: 'custom-' + Date.now(),
      title: customTitle,
      category: 'Cosmetics & Beauty',
      duration: '0:34',
      thumbnailUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=400&q=80',
      videoUrl: objectUrl,
      description: 'Uploaded reference video.',
      topics: ['beauty', 'luxury cosmetics', 'lipstick application'],
      objects: ['lipstick bullet', 'applicator', 'packaging'],
      visualStyle: ['macro slow-motion', 'studio lighting', 'velvet texture'],
      pacing: 'Slow & sensual',
      mood: 'Elegant, premium'
    };

    this.syncGlobalState();
    if (window.showToast) window.showToast(`Loaded reference: ${customTitle}`, 'success');
  }

  setReferencePreset(preset) {
    this.currentReference = preset;
    if (this.previewFilename) this.previewFilename.textContent = (preset.id === 'ref-luxury-lipstick' ? 'lipstick_demo.mp4' : preset.title);
    if (this.previewFilesize) this.previewFilesize.textContent = '24.6 MB';
    if (this.previewThumb) this.previewThumb.src = preset.thumbnailUrl;

    if (preset.defaultKeywords && preset.defaultKeywords.length > 0) {
      this.keywords = [...preset.defaultKeywords];
      this.renderKeywords();
    }
    this.syncGlobalState();
  }

  updateSelectedPlatforms() {
    this.selectedPlatforms = [];
    this.platformCards.forEach(card => {
      if (card.classList.contains('selected')) {
        this.selectedPlatforms.push(card.dataset.platform);
      }
    });
    this.syncGlobalState();
  }

  syncGlobalState() {
    window.videoFindAppState = window.videoFindAppState || {};
    window.videoFindAppState.currentReference = this.currentReference;
    window.videoFindAppState.userKeywords = this.keywords;
    window.videoFindAppState.userDescription = this.descriptionInput ? this.descriptionInput.value : '';
    window.videoFindAppState.selectedPlatforms = this.selectedPlatforms;
  }

  async executeSearch(directQuery = null) {
    if (this.selectedPlatforms.length === 0) {
      if (window.showToast) window.showToast('Please select at least one platform', 'warning');
      return;
    }

    this.btnFindSimilar.disabled = true;
    this.btnFindSimilar.innerHTML = `
      <svg class="animate-spin" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
      </svg>
      Scanning Social Platforms...
    `;

    try {
      this.syncGlobalState();

      const payload = {
        referenceContext: this.currentReference || {
          title: 'lipstick_demo.mp4',
          category: 'Beauty & Cosmetics',
          topics: ['beauty', 'luxury cosmetics', 'lipstick application']
        },
        keywords: this.keywords,
        platforms: this.selectedPlatforms,
        query: directQuery || (this.descriptionInput ? this.descriptionInput.value : ''),
        sortBy: this.sortSelect ? this.sortSelect.value : 'relevance'
      };

      const result = await api.searchVideos(payload);

      window.videoFindAppState.searchResults = result.results;
      window.videoFindAppState.lastSearchQuery = payload.query;

      // Navigate to results
      if (window.videoFindAppRouter) {
        window.videoFindAppRouter.navigateTo('results');
      }
      if (window.videoFindResultsController) {
        window.videoFindResultsController.renderResults(result);
      }

      if (window.showToast) {
        window.showToast(`Found ${result.total} matching videos!`, 'success');
      }
    } catch (err) {
      if (window.showToast) window.showToast('Search failed: ' + err.message, 'error');
    } finally {
      this.btnFindSimilar.disabled = false;
      this.btnFindSimilar.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <circle cx="11" cy="11" r="8"/>
          <line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        Find Similar Videos
      `;
    }
  }
}

export let searchControllerInstance = null;

export function initSearchController() {
  searchControllerInstance = new SearchController();
  window.videoFindSearchController = searchControllerInstance;
  return searchControllerInstance;
}

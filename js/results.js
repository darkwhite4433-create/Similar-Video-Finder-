/**
 * VideoFind AI - Results Controller (Light Theme Matching Screenshot)
 */

import { api } from './api.js';

class ResultsController {
  constructor() {
    this.results = [];
    this.savedIds = new Set();
    this.activePreviewVideo = null;

    // DOM Elements
    this.cardsGrid = document.getElementById('results-cards-grid');
    this.btnBackToSearch = document.getElementById('btn-back-to-search');
    this.btnAskGeminiResults = document.getElementById('btn-results-ask-gemini');

    // Modal
    this.modal = document.getElementById('video-preview-modal');
    this.modalClose = document.getElementById('btn-close-modal');
    this.modalPlayer = document.getElementById('modal-player');
    this.modalTitle = document.getElementById('modal-video-title');
    this.modalPlatform = document.getElementById('modal-video-platform');
    this.modalScore = document.getElementById('modal-score');
    this.modalWhy = document.getElementById('modal-why-text');
    this.modalBtnAskGemini = document.getElementById('modal-btn-ask-gemini');

    this.init();
  }

  init() {
    if (this.btnBackToSearch) {
      this.btnBackToSearch.addEventListener('click', () => {
        if (window.videoFindAppRouter) window.videoFindAppRouter.navigateTo('search');
      });
    }

    if (this.btnAskGeminiResults) {
      this.btnAskGeminiResults.addEventListener('click', () => {
        if (window.geminiAssistant) window.geminiAssistant.triggerQuickAction('explain-results');
      });
    }

    if (this.modalClose && this.modal) {
      this.modalClose.addEventListener('click', () => this.closeModal());
      this.modal.addEventListener('click', (e) => {
        if (e.target === this.modal) this.closeModal();
      });
    }

    if (this.modalBtnAskGemini) {
      this.modalBtnAskGemini.addEventListener('click', () => {
        if (this.activePreviewVideo && window.geminiAssistant) {
          window.geminiAssistant.askAboutResult(this.activePreviewVideo);
        }
      });
    }

    this.refreshSavedIds();
  }

  async refreshSavedIds() {
    try {
      const data = await api.getSavedVideos();
      this.savedIds = new Set((data.savedVideos || []).map(v => v.id));
    } catch (_) {}
  }

  renderResults(data) {
    this.results = data.results || [];
    this.refreshSavedIds().then(() => this.buildGrid());
  }

  buildGrid() {
    if (!this.cardsGrid) return;
    this.cardsGrid.innerHTML = '';

    if (this.results.length === 0) {
      this.cardsGrid.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-muted);">
          No matching videos found. Try selecting additional platforms or adjusting keywords.
        </div>
      `;
      return;
    }

    this.results.forEach(video => {
      const card = document.createElement('div');
      card.className = 'video-result-item animate-fade-in';
      const isSaved = this.savedIds.has(video.id);

      let badgeBg = '#ff0000';
      const pLower = (video.platform || '').toLowerCase();
      if (pLower.includes('facebook')) badgeBg = '#1877f2';
      else if (pLower.includes('instagram')) badgeBg = '#e1306c';
      else if (pLower.includes('tiktok')) badgeBg = '#000000';

      card.innerHTML = `
        <div class="result-thumb-area">
          <img class="result-thumb-img" src="${video.thumbnailUrl}" alt="${video.title}" />
          <span class="result-badge-pill" style="background: ${badgeBg};">${video.platform}</span>
          <span class="result-duration-pill">${video.duration}</span>
        </div>
        <div class="result-content-body">
          <div class="result-creator-row">
            <img class="result-creator-avatar" src="${video.creatorAvatar}" alt="${video.creator}" />
            <span class="result-creator-name">${video.creator}</span>
            <span style="font-size: 11px; color: var(--text-muted); margin-left: auto;">${video.views}</span>
          </div>
          <h4 class="result-video-title" title="${video.title}">${video.title}</h4>
          
          <div class="result-score-box">
            <span class="result-score-text">${video.matchScore}% AI Match</span>
            <span style="font-size: 11px; color: #64748b;">${video.published}</span>
          </div>

          <div class="result-why-box">
            <strong>Why it matches:</strong> ${video.whyMatches}
          </div>

          <div class="result-actions-bottom">
            <div style="display: flex; gap: 6px;">
              <button class="btn btn-sm ${isSaved ? 'btn-primary' : 'btn-outline'} btn-card-save">
                ${isSaved ? 'Saved' : 'Save'}
              </button>
              <button class="btn btn-sm btn-secondary btn-card-preview">Preview</button>
            </div>
            <button class="btn btn-sm btn-outline btn-card-gemini" style="color: var(--primary-blue); border-color: #bfdbfe;">
              Ask Gemini
            </button>
          </div>
        </div>
      `;

      // Event listeners
      card.querySelector('.btn-card-preview').addEventListener('click', () => this.openModal(video));
      
      const saveBtn = card.querySelector('.btn-card-save');
      saveBtn.addEventListener('click', async () => {
        const willSave = !this.savedIds.has(video.id);
        if (willSave) {
          await api.saveVideo(video);
          this.savedIds.add(video.id);
          saveBtn.className = 'btn btn-sm btn-primary btn-card-save';
          saveBtn.textContent = 'Saved';
          if (window.showToast) window.showToast('Saved video to collection', 'success');
        } else {
          await api.removeSavedVideo(video.id);
          this.savedIds.delete(video.id);
          saveBtn.className = 'btn btn-sm btn-outline btn-card-save';
          saveBtn.textContent = 'Save';
          if (window.showToast) window.showToast('Removed from saved list', 'info');
        }
      });

      card.querySelector('.btn-card-gemini').addEventListener('click', () => {
        if (window.geminiAssistant) window.geminiAssistant.askAboutResult(video);
      });

      this.cardsGrid.appendChild(card);
    });
  }

  openModal(video) {
    this.activePreviewVideo = video;
    if (!this.modal) return;
    this.modalTitle.textContent = video.title;
    this.modalPlatform.textContent = video.platform;
    this.modalScore.textContent = `${video.matchScore}% AI Match`;
    this.modalWhy.textContent = video.whyMatches;
    this.modalPlayer.src = video.videoUrl;
    this.modalPlayer.play().catch(() => {});
    this.modal.classList.add('active');
  }

  closeModal() {
    if (!this.modal) return;
    this.modalPlayer.pause();
    this.modalPlayer.src = '';
    this.modal.classList.remove('active');
    this.activePreviewVideo = null;
  }
}

export let resultsControllerInstance = null;

export function initResultsController() {
  resultsControllerInstance = new ResultsController();
  window.videoFindResultsController = resultsControllerInstance;
  return resultsControllerInstance;
}

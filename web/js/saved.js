/**
 * VideoFind AI - Saved Videos & History Controller
 * Handles saved collection, exports, and search history re-running.
 */

import { api } from './api.js';

class SavedAndHistoryController {
  constructor() {
    this.savedVideos = [];
    this.historyItems = [];
    this.savedPlatformFilter = 'all';

    // DOM Elements - Saved Videos
    this.savedContainer = document.getElementById('saved-videos-grid');
    this.savedEmptyState = document.getElementById('saved-empty-state');
    this.savedFilterTabs = document.getElementById('saved-filter-tabs');
    this.btnExportCsv = document.getElementById('btn-export-csv');
    this.btnExportJson = document.getElementById('btn-export-json');

    // DOM Elements - History
    this.historyContainer = document.getElementById('history-list');
    this.historyEmptyState = document.getElementById('history-empty-state');
    this.btnClearHistory = document.getElementById('btn-clear-history');

    this.init();
  }

  init() {
    // Export buttons
    if (this.btnExportCsv) {
      this.btnExportCsv.addEventListener('click', () => this.exportCsv());
    }
    if (this.btnExportJson) {
      this.btnExportJson.addEventListener('click', () => this.exportJson());
    }

    // Filter tabs
    if (this.savedFilterTabs) {
      this.savedFilterTabs.addEventListener('click', (e) => {
        const tab = e.target.closest('.filter-pill');
        if (!tab) return;
        this.savedFilterTabs.querySelectorAll('.filter-pill').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        this.savedPlatformFilter = tab.dataset.platform;
        this.renderSavedVideos();
      });
    }

    // Clear history
    if (this.btnClearHistory) {
      this.btnClearHistory.addEventListener('click', async () => {
        if (confirm('Clear all search history?')) {
          await api.clearHistory();
          this.historyItems = [];
          this.renderHistory();
          if (window.showToast) window.showToast('Search history cleared', 'info');
        }
      });
    }

    this.loadSavedVideos();
    this.loadHistory();
  }

  async loadSavedVideos() {
    try {
      const data = await api.getSavedVideos();
      this.savedVideos = data.savedVideos || [];
      this.renderSavedVideos();
      this.updateNavbarBadge();
    } catch (_) {}
  }

  async loadHistory() {
    try {
      const data = await api.getHistory();
      this.historyItems = data.history || [];
      this.renderHistory();
    } catch (_) {}
  }

  updateNavbarBadge() {
    const badge = document.getElementById('nav-saved-count');
    if (badge) {
      badge.textContent = this.savedVideos.length;
      badge.style.display = this.savedVideos.length > 0 ? 'inline-flex' : 'none';
    }
  }

  renderSavedVideos() {
    if (!this.savedContainer) return;

    let items = [...this.savedVideos];
    if (this.savedPlatformFilter !== 'all') {
      const target = this.savedPlatformFilter.toLowerCase().replaceAll('/', '').replaceAll(' ', '');
      items = items.filter(i => {
        const p = (i.platform || '').toLowerCase().replaceAll('/', '').replaceAll(' ', '');
        return p.includes(target) || target.includes(p);
      });
    }

    this.savedContainer.innerHTML = '';

    if (items.length === 0) {
      if (this.savedEmptyState) this.savedEmptyState.style.display = 'block';
      return;
    }

    if (this.savedEmptyState) this.savedEmptyState.style.display = 'none';

    items.forEach(video => {
      const card = document.createElement('div');
      card.className = 'result-card animate-fade-in';
      card.innerHTML = `
        <div class="result-card-media">
          <img class="result-card-thumb" src="${video.thumbnailUrl}" alt="${video.title}" />
          <span class="result-platform-badge ${this.getPlatformBadgeClass(video.platform)}">${video.platform}</span>
          <span class="result-card-duration">${video.duration}</span>
        </div>
        <div class="result-card-body">
          <div class="result-card-creator">
            <img class="creator-avatar" src="${video.creatorAvatar}" alt="${video.creator}" />
            <span class="creator-name">${video.creator}</span>
          </div>
          <h3 class="result-card-title">${video.title}</h3>
          <div class="result-match-score-row">
            <span class="score-badge-pill">${video.matchScore}% AI Match</span>
            <span style="font-size: 11px; color: var(--text-muted);">${video.views}</span>
          </div>
          <div class="result-actions-row">
            <button class="btn btn-sm btn-outline btn-remove-saved">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
              Remove
            </button>
            <button class="btn btn-sm btn-gemini btn-ask-gemini">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2L14.4 9.6L22 12L14.4 14.4L12 22L9.6 14.4L2 12L9.6 9.6L12 2Z"/></svg>
              Ask Gemini
            </button>
          </div>
        </div>
      `;

      card.querySelector('.btn-remove-saved').addEventListener('click', async () => {
        await api.removeSavedVideo(video.id);
        this.loadSavedVideos();
        if (window.showToast) window.showToast('Removed video from saved list', 'info');
      });

      card.querySelector('.btn-ask-gemini').addEventListener('click', () => {
        if (window.geminiAssistant) window.geminiAssistant.askAboutResult(video);
      });

      this.savedContainer.appendChild(card);
    });
  }

  renderHistory() {
    if (!this.historyContainer) return;
    this.historyContainer.innerHTML = '';

    if (this.historyItems.length === 0) {
      if (this.historyEmptyState) this.historyEmptyState.style.display = 'block';
      return;
    }

    if (this.historyEmptyState) this.historyEmptyState.style.display = 'none';

    this.historyItems.forEach(item => {
      const card = document.createElement('div');
      card.className = 'history-item-card animate-fade-in';
      const dateStr = new Date(item.timestamp).toLocaleString();

      card.innerHTML = `
        <div>
          <div style="font-weight: 700; font-size: 15px; color: var(--text-main); margin-bottom: 4px;">
            ${item.referenceTitle}
          </div>
          <div style="font-size: 12px; color: var(--text-secondary); display: flex; gap: 12px; flex-wrap: wrap;">
            <span>Category: <strong>${item.category}</strong></span>
            <span>Results: <strong>${item.resultCount}</strong></span>
            <span>Top Match: <strong>${item.topScore}%</strong></span>
            <span>Date: ${dateStr}</span>
          </div>
          <div style="margin-top: 6px; display: flex; gap: 4px; flex-wrap: wrap;">
            ${(item.keywords || []).slice(0, 4).map(k => `<span class="matched-kw-pill">#${k}</span>`).join('')}
          </div>
        </div>
        <div>
          <button class="btn btn-sm btn-primary btn-rerun-search">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
            Re-run Search
          </button>
        </div>
      `;

      card.querySelector('.btn-rerun-search').addEventListener('click', () => {
        this.rerunSearch(item);
      });

      this.historyContainer.appendChild(card);
    });
  }

  async rerunSearch(historyItem) {
    if (window.videoFindSearchController && window.videoFindAppRouter) {
      window.videoFindAppRouter.navigateTo('search');
      // If matches preset, select it
      const presets = (await api.getPresets()).presets || [];
      const match = presets.find(p => p.title === historyItem.referenceTitle);
      if (match) {
        await window.videoFindSearchController.setReferencePreset(match);
      }
      if (historyItem.keywords) {
        window.videoFindSearchController.addKeywords(historyItem.keywords);
      }
      window.videoFindSearchController.executeSearch(historyItem.query);
      if (window.showToast) window.showToast('Re-running search...', 'info');
    }
  }

  exportCsv() {
    if (this.savedVideos.length === 0) {
      if (window.showToast) window.showToast('No saved videos to export', 'warning');
      return;
    }
    const headers = ['ID', 'Title', 'Platform', 'Creator', 'MatchScore', 'Duration', 'Views', 'VideoURL'];
    const rows = this.savedVideos.map(v => [
      `"${v.id}"`,
      `"${(v.title || '').replace(/"/g, '""')}"`,
      `"${v.platform}"`,
      `"${v.creator}"`,
      v.matchScore,
      `"${v.duration}"`,
      `"${v.views}"`,
      `"${v.videoUrl}"`
    ]);

    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `videofind_saved_${Date.now()}.csv`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    if (window.showToast) window.showToast('Exported saved videos as CSV', 'success');
  }

  exportJson() {
    if (this.savedVideos.length === 0) {
      if (window.showToast) window.showToast('No saved videos to export', 'warning');
      return;
    }
    const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(this.savedVideos, null, 2));
    const link = document.createElement('a');
    link.setAttribute('href', dataStr);
    link.setAttribute('download', `videofind_saved_${Date.now()}.json`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    if (window.showToast) window.showToast('Exported saved videos as JSON', 'success');
  }

  getPlatformBadgeClass(platform) {
    const p = (platform || '').toLowerCase();
    if (p.includes('youtube')) return 'badge-youtube';
    if (p.includes('tiktok')) return 'badge-tiktok';
    if (p.includes('instagram')) return 'badge-instagram';
    if (p.includes('twitter') || p.includes('x')) return 'badge-twitter';
    if (p.includes('vimeo')) return 'badge-vimeo';
    return 'badge-youtube';
  }
}

export let savedControllerInstance = null;

export function initSavedController() {
  savedControllerInstance = new SavedAndHistoryController();
  window.videoFindSavedController = savedControllerInstance;
  return savedControllerInstance;
}

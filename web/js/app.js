/**
 * VideoFind AI - Main App Coordinator & Router
 */

import { api } from './api.js';
import { initGeminiAssistant } from './gemini.js';
import { initSearchController } from './search.js';
import { initResultsController } from './results.js';

class AppRouter {
  constructor() {
    this.currentView = 'search'; // Default to New Search matching screenshot
    this.views = {
      dashboard: document.getElementById('view-dashboard'),
      search: document.getElementById('view-search'),
      results: document.getElementById('view-results'),
      saved: document.getElementById('view-saved'),
      history: document.getElementById('view-history'),
      settings: document.getElementById('view-settings'),
    };

    this.navItems = document.querySelectorAll('.top-nav-item, .sidebar-nav-item');
    this.init();
  }

  init() {
    this.navItems.forEach(item => {
      item.addEventListener('click', () => {
        const targetView = item.dataset.view;
        if (targetView) this.navigateTo(targetView);
      });
    });

    const homeLogo = document.getElementById('logo-home-link');
    if (homeLogo) {
      homeLogo.addEventListener('click', (e) => {
        e.preventDefault();
        this.navigateTo('search');
      });
    }

    // Default to search
    this.navigateTo('search');
  }

  navigateTo(viewName) {
    if (!this.views[viewName]) return;
    this.currentView = viewName;

    Object.keys(this.views).forEach(k => {
      if (this.views[k]) {
        if (k === 'results') {
          this.views[k].classList.toggle('active', k === viewName);
          this.views[k].style.display = k === viewName ? 'block' : 'none';
        } else {
          this.views[k].style.display = k === viewName ? 'block' : 'none';
        }
      }
    });

    this.navItems.forEach(item => {
      item.classList.toggle('active', item.dataset.view === viewName);
    });

    window.scrollTo({ top: 0, behavior: 'smooth' });

    if (viewName === 'saved') loadSavedVideos();
    if (viewName === 'history') loadHistory();
    if (viewName === 'dashboard') loadDashboardPresets();
  }
}

// Global Toast helper
window.showToast = function(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;
  const toast = document.createElement('div');
  toast.className = 'toast';
  toast.innerHTML = `<span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.2s ease';
    setTimeout(() => toast.remove(), 200);
  }, 3000);
};

// Saved Videos Logic
async function loadSavedVideos() {
  const grid = document.getElementById('saved-cards-grid');
  const empty = document.getElementById('saved-empty-hint');
  if (!grid) return;

  try {
    const data = await api.getSavedVideos();
    const list = data.savedVideos || [];
    grid.innerHTML = '';
    if (list.length === 0) {
      if (empty) empty.style.display = 'block';
      return;
    }
    if (empty) empty.style.display = 'none';

    list.forEach(video => {
      const card = document.createElement('div');
      card.className = 'video-result-item';
      card.innerHTML = `
        <div class="result-thumb-area">
          <img class="result-thumb-img" src="${video.thumbnailUrl}" alt="${video.title}" />
          <span class="result-badge-pill" style="background: #2563eb;">${video.platform}</span>
          <span class="result-duration-pill">${video.duration}</span>
        </div>
        <div class="result-content-body">
          <h4 class="result-video-title">${video.title}</h4>
          <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 8px;">${video.creator} • ${video.views}</div>
          <div class="result-score-box">
            <span class="result-score-text">${video.matchScore}% Match</span>
          </div>
          <div class="result-actions-bottom">
            <button class="btn btn-sm btn-outline btn-del-saved">Remove</button>
            <button class="btn btn-sm btn-primary btn-saved-ask-gemini">Ask Gemini</button>
          </div>
        </div>
      `;

      card.querySelector('.btn-del-saved').addEventListener('click', async () => {
        await api.removeSavedVideo(video.id);
        loadSavedVideos();
        window.showToast('Removed saved video', 'info');
      });

      card.querySelector('.btn-saved-ask-gemini').addEventListener('click', () => {
        if (window.geminiAssistant) window.geminiAssistant.askAboutResult(video);
      });

      grid.appendChild(card);
    });
  } catch (_) {}
}

// Search History Logic
async function loadHistory() {
  const feed = document.getElementById('history-items-feed');
  if (!feed) return;
  try {
    const data = await api.getHistory();
    const list = data.history || [];
    feed.innerHTML = '';
    if (list.length === 0) {
      feed.innerHTML = '<div style="color: var(--text-muted); padding: 20px;">No search history recorded yet.</div>';
      return;
    }

    list.forEach(item => {
      const el = document.createElement('div');
      el.style.cssText = 'background: #f8fafc; border: 1px solid var(--border-subtle); border-radius: 12px; padding: 14px; display: flex; align-items: center; justify-content: space-between;';
      el.innerHTML = `
        <div>
          <div style="font-weight: 700; font-size: 14px; color: var(--text-main);">${item.referenceTitle}</div>
          <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
            ${item.resultCount} results • Platforms: ${(item.platforms || []).join(', ')} • ${new Date(item.timestamp).toLocaleTimeString()}
          </div>
        </div>
        <button class="btn btn-sm btn-primary btn-hist-rerun">Re-run</button>
      `;
      el.querySelector('.btn-hist-rerun').addEventListener('click', () => {
        if (window.videoFindSearchController && window.videoFindAppRouter) {
          window.videoFindAppRouter.navigateTo('search');
          window.videoFindSearchController.executeSearch(item.query);
        }
      });
      feed.appendChild(el);
    });
  } catch (_) {}
}

// Dashboard Presets List
async function loadDashboardPresets() {
  const container = document.getElementById('dash-presets-list');
  if (!container) return;
  try {
    const data = await api.getPresets();
    const list = data.presets || [];
    container.innerHTML = '';
    list.forEach(p => {
      const card = document.createElement('div');
      card.style.cssText = 'background: #ffffff; border: 1px solid var(--border-subtle); border-radius: 12px; padding: 12px; display: flex; gap: 12px; cursor: pointer;';
      card.innerHTML = `
        <img src="${p.thumbnailUrl}" style="width: 60px; height: 60px; border-radius: 8px; object-fit: cover;" />
        <div>
          <div style="font-weight: 700; font-size: 13.5px;">${p.title}</div>
          <div style="font-size: 12px; color: var(--text-muted);">${p.category} • ${p.duration}</div>
        </div>
      `;
      card.addEventListener('click', () => {
        if (window.videoFindSearchController && window.videoFindAppRouter) {
          window.videoFindSearchController.setReferencePreset(p);
          window.videoFindAppRouter.navigateTo('search');
        }
      });
      container.appendChild(card);
    });
  } catch (_) {}
}

// Settings Logic
async function initSettings() {
  const keyInput = document.getElementById('input-api-key');
  const modelSelect = document.getElementById('select-model');
  const saveBtn = document.getElementById('btn-save-cfg');
  if (!saveBtn) return;

  try {
    const cfg = await api.getSettings();
    if (modelSelect) modelSelect.value = cfg.geminiModel || 'gemini-2.0-flash';
    if (keyInput && cfg.hasApiKey) keyInput.placeholder = cfg.maskedApiKey;
  } catch (_) {}

  saveBtn.addEventListener('click', async () => {
    const apiKey = keyInput.value.trim();
    const model = modelSelect.value;
    try {
      await api.updateSettings({
        geminiApiKey: apiKey.length > 0 ? apiKey : undefined,
        geminiModel: model
      });
      window.showToast('Settings saved successfully!', 'success');
      if (apiKey) keyInput.value = '';
    } catch (_) {
      window.showToast('Failed to save settings', 'error');
    }
  });

  const exportCsvBtn = document.getElementById('btn-export-saved-csv');
  if (exportCsvBtn) {
    exportCsvBtn.addEventListener('click', async () => {
      const data = await api.getSavedVideos();
      const list = data.savedVideos || [];
      const csv = 'Title,Platform,Creator,Score\n' + list.map(v => `"${v.title}","${v.platform}","${v.creator}",${v.matchScore}`).join('\n');
      const blob = new Blob([csv], { type: 'text/csv' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'saved_videos.csv';
      a.click();
    });
  }

  const clearHistBtn = document.getElementById('btn-clear-history-all');
  if (clearHistBtn) {
    clearHistBtn.addEventListener('click', async () => {
      if (confirm('Clear all search history?')) {
        await api.clearHistory();
        loadHistory();
        window.showToast('Search history cleared', 'info');
      }
    });
  }
}

// App Bootstrap
document.addEventListener('DOMContentLoaded', async () => {
  window.videoFindAppState = {
    currentReference: null,
    userKeywords: ['beauty', 'lipstick', 'makeup', 'cosmetics', 'luxury'],
    selectedPlatforms: ['YouTube', 'Facebook'],
    searchResults: []
  };

  window.videoFindAppRouter = new AppRouter();
  initGeminiAssistant();
  const searchCtrl = initSearchController();
  initResultsController();
  initSettings();

  // Load initial preset
  try {
    const res = await api.getPresets();
    if (res.presets && res.presets.length > 0) {
      searchCtrl.setReferencePreset(res.presets[0]);
    }
  } catch (_) {}
});

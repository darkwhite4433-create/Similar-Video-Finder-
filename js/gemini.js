/**
 * VideoFind AI - Built-in Gemini Assistant Controller
 * Matches screenshot layout: docked/floating panel, scope selector, quick action grid, in-chat responses.
 */

import { api } from './api.js';

class GeminiAssistant {
  constructor() {
    this.isOpen = true; // Docked open by default on desktop like screenshot
    this.sessionId = 'session-' + Date.now();
    this.contextMode = 'current-search';
    this.isThinking = false;
    this.messages = [];

    // DOM Elements
    this.panel = document.getElementById('gemini-docked-panel');
    this.fabBtn = document.getElementById('btn-gemini-fab');
    this.closeBtn = document.getElementById('btn-close-gemini');
    this.scopePills = document.querySelectorAll('.scope-pill');
    this.chatScroll = document.getElementById('gemini-chat-scroll');
    this.inputField = document.getElementById('gemini-chat-input');
    this.sendBtn = document.getElementById('btn-gemini-send');
    this.quickActionBtns = document.querySelectorAll('.qa-card-btn');

    this.init();
  }

  init() {
    if (!this.panel) return;

    // Toggle panel via FAB or top nav button
    if (this.fabBtn) {
      this.fabBtn.addEventListener('click', () => this.togglePanel());
    }
    const topGeminiBtn = document.getElementById('top-gemini-toggle');
    if (topGeminiBtn) {
      topGeminiBtn.addEventListener('click', () => this.togglePanel());
    }

    // Close button
    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.closePanel());
    }

    // Scope pills
    this.scopePills.forEach(pill => {
      pill.addEventListener('click', () => {
        this.scopePills.forEach(p => p.classList.remove('active'));
        pill.classList.add('active');
        this.contextMode = pill.dataset.scope;
      });
    });

    // Send button & Enter key
    if (this.sendBtn && this.inputField) {
      this.sendBtn.addEventListener('click', () => this.handleSendMessage());
      this.inputField.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.handleSendMessage();
        }
      });
    }

    // Quick Action Cards
    this.quickActionBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.action;
        this.triggerQuickAction(action);
      });
    });
  }

  togglePanel() {
    if (this.isOpen) {
      this.closePanel();
    } else {
      this.openPanel();
    }
  }

  openPanel() {
    this.isOpen = true;
    if (this.panel) {
      this.panel.style.display = 'flex';
      this.panel.style.opacity = '1';
    }
    if (this.inputField) this.inputField.focus();
    this.scrollToBottom();
  }

  closePanel() {
    this.isOpen = false;
    if (this.panel) {
      this.panel.style.display = 'none';
    }
  }

  getStructuredContext() {
    const appState = window.videoFindAppState || {};
    if (this.contextMode === 'current-video') {
      return {
        referenceVideo: appState.currentReference || {
          title: 'lipstick_demo.mp4',
          category: 'Cosmetics & Beauty',
          topics: ['beauty', 'luxury cosmetics', 'lipstick application']
        },
        userKeywords: appState.userKeywords || []
      };
    }
    if (this.contextMode === 'search-results') {
      return {
        searchResults: (appState.searchResults || []).slice(0, 6)
      };
    }
    return {
      referenceVideo: appState.currentReference || {
        title: 'lipstick_demo.mp4',
        category: 'Cosmetics & Beauty',
        topics: ['beauty', 'luxury cosmetics', 'lipstick application']
      },
      userKeywords: appState.userKeywords || [],
      selectedPlatforms: appState.selectedPlatforms || ['YouTube', 'Facebook'],
      searchResults: (appState.searchResults || []).slice(0, 6)
    };
  }

  addMessage(role, text, options = {}) {
    this.messages.push({ role, text, ...options });
    const item = document.createElement('div');
    item.className = `gemini-msg-item ${role}`;

    let avatarHtml = '';
    if (role === 'gemini') {
      avatarHtml = `
        <div class="gemini-avatar-sparkle">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2L14.4 9.6L22 12L14.4 14.4L12 22L9.6 14.4L2 12L9.6 9.6L12 2Z"/>
          </svg>
        </div>
      `;
    }

    const formattedBody = this.formatMarkdown(text);
    let actionHtml = '';
    if (options.keywords && options.keywords.length > 0) {
      actionHtml = `
        <div class="bubble-action-row">
          <button class="btn-bubble-action btn-import-kw" data-kw='${JSON.stringify(options.keywords)}'>
            Use These Keywords (${options.keywords.length})
          </button>
        </div>
      `;
    }

    item.innerHTML = `
      ${avatarHtml}
      <div class="gemini-msg-bubble">
        ${formattedBody}
        ${actionHtml}
      </div>
    `;

    // Bind action button
    const kwBtn = item.querySelector('.btn-import-kw');
    if (kwBtn) {
      kwBtn.addEventListener('click', (e) => {
        try {
          const kws = JSON.parse(e.currentTarget.dataset.kw);
          if (window.videoFindSearchController) {
            window.videoFindSearchController.addKeywords(kws);
            if (window.showToast) window.showToast(`Imported ${kws.length} keywords!`, 'success');
          }
        } catch (_) {}
      });
    }

    if (this.chatScroll) {
      this.chatScroll.appendChild(item);
      this.scrollToBottom();
    }
  }

  showThinking() {
    this.isThinking = true;
    if (this.sendBtn) this.sendBtn.disabled = true;
    const thinkingEl = document.createElement('div');
    thinkingEl.id = 'gemini-thinking-bubble';
    thinkingEl.className = 'gemini-thinking-indicator';
    thinkingEl.innerHTML = `
      <svg class="animate-spin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 12a9 9 0 1 1-6.219-8.56"/></svg>
      <span>Thinking...</span>
    `;
    if (this.chatScroll) {
      this.chatScroll.appendChild(thinkingEl);
      this.scrollToBottom();
    }
  }

  hideThinking() {
    this.isThinking = false;
    if (this.sendBtn) this.sendBtn.disabled = false;
    const el = document.getElementById('gemini-thinking-bubble');
    if (el) el.remove();
  }

  scrollToBottom() {
    if (this.chatScroll) {
      this.chatScroll.scrollTop = this.chatScroll.scrollHeight;
    }
  }

  async handleSendMessage() {
    const text = this.inputField.value.trim();
    if (!text || this.isThinking) return;

    this.inputField.value = '';
    this.addMessage('user', text);
    this.showThinking();

    try {
      const context = this.getStructuredContext();
      const res = await api.geminiChat(text, this.sessionId, context);
      this.hideThinking();
      this.addMessage('gemini', res.text || 'Understood.', { keywords: res.keywords });
    } catch (_) {
      this.hideThinking();
      this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
    }
  }

  async triggerQuickAction(action) {
    if (this.isThinking) return;
    this.openPanel();
    const context = this.getStructuredContext();

    if (action === 'improve-keywords') {
      this.addMessage('user', 'Improve keywords for this video.');
      this.showThinking();
      try {
        const res = await api.geminiKeywords(this.sessionId, context);
        this.hideThinking();
        this.addMessage('gemini', res.text, { keywords: res.keywords });
      } catch (_) {
        this.hideThinking();
        this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
      }
      return;
    }

    if (action === 'generate-queries' || action === 'suggest-queries') {
      this.addMessage('user', 'Generate better search queries.');
      this.showThinking();
      try {
        const res = await api.geminiQueries(this.sessionId, context);
        this.hideThinking();
        this.addMessage('gemini', res.text);
      } catch (_) {
        this.hideThinking();
        this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
      }
      return;
    }

    if (action === 'find-ideas') {
      this.addMessage('user', 'Find content ideas based on this reference.');
      this.showThinking();
      try {
        const res = await api.geminiIdeas(this.sessionId, context);
        this.hideThinking();
        this.addMessage('gemini', res.text);
      } catch (_) {
        this.hideThinking();
        this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
      }
      return;
    }

    if (action === 'analyze-reference') {
      this.addMessage('user', 'Analyze my reference video aesthetics and pacing.');
      this.showThinking();
      try {
        const res = await api.geminiChat('Analyze my reference video aesthetics, topics, and pacing in detail.', this.sessionId, context);
        this.hideThinking();
        this.addMessage('gemini', res.text);
      } catch (_) {
        this.hideThinking();
        this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
      }
      return;
    }

    if (action === 'explain-results') {
      this.addMessage('user', 'Explain results and performance breakdown.');
      this.showThinking();
      try {
        const res = await api.geminiSummarize(this.sessionId, context);
        this.hideThinking();
        this.addMessage('gemini', res.text);
      } catch (_) {
        this.hideThinking();
        this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
      }
      return;
    }
  }

  async askAboutResult(video) {
    this.openPanel();
    this.addMessage('user', `Explain why "${video.title}" is relevant to my reference video.`);
    this.showThinking();
    try {
      const context = this.getStructuredContext();
      const res = await api.geminiExplain(this.sessionId, video, context);
      this.hideThinking();
      this.addMessage('gemini', res.text);
    } catch (_) {
      this.hideThinking();
      this.addMessage('gemini', 'Gemini Assistant is temporarily unavailable.');
    }
  }

  formatMarkdown(raw) {
    if (!raw) return '';
    return raw
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
      .replace(/`([^`]+)`/gim, '<code>$1</code>')
      .replace(/\[KEYWORDS:.*?\]/gim, '')
      .replace(/\n/g, '<br/>');
  }
}

export let geminiAssistantInstance = null;

export function initGeminiAssistant() {
  geminiAssistantInstance = new GeminiAssistant();
  window.geminiAssistant = geminiAssistantInstance;
  return geminiAssistantInstance;
}

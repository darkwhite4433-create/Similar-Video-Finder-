/**
 * VideoFind AI - API Client
 * Securely communicates with the backend server.
 */

const API_BASE = '';

export const api = {
  async getPresets() {
    const res = await fetch(`${API_BASE}/api/presets`);
    if (!res.ok) throw new Error('Failed to fetch video presets');
    return await res.json();
  },

  async analyzeVideo(payload) {
    const res = await fetch(`${API_BASE}/api/analyze-video`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error('Failed to analyze reference video');
    return await res.json();
  },

  async searchVideos(payload) {
    const res = await fetch(`${API_BASE}/api/search`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error('Failed to execute search');
    return await res.json();
  },

  async getSavedVideos() {
    const res = await fetch(`${API_BASE}/api/saved`);
    if (!res.ok) throw new Error('Failed to fetch saved videos');
    return await res.json();
  },

  async saveVideo(video) {
    const res = await fetch(`${API_BASE}/api/saved`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ video })
    });
    if (!res.ok) throw new Error('Failed to save video');
    return await res.json();
  },

  async removeSavedVideo(id) {
    const res = await fetch(`${API_BASE}/api/saved/${encodeURIComponent(id)}`, {
      method: 'DELETE'
    });
    if (!res.ok) throw new Error('Failed to remove saved video');
    return await res.json();
  },

  async getHistory() {
    const res = await fetch(`${API_BASE}/api/history`);
    if (!res.ok) throw new Error('Failed to fetch search history');
    return await res.json();
  },

  async clearHistory() {
    const res = await fetch(`${API_BASE}/api/history`, {
      method: 'DELETE'
    });
    if (!res.ok) throw new Error('Failed to clear search history');
    return await res.json();
  },

  async getSettings() {
    const res = await fetch(`${API_BASE}/api/settings`);
    if (!res.ok) throw new Error('Failed to fetch settings');
    return await res.json();
  },

  async updateSettings(payload) {
    const res = await fetch(`${API_BASE}/api/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error('Failed to update settings');
    return await res.json();
  },

  // Gemini Endpoints
  async geminiChat(message, sessionId, context) {
    const res = await fetch(`${API_BASE}/api/gemini/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, sessionId, context })
    });
    return await res.json();
  },

  async geminiKeywords(sessionId, context, customFocus) {
    const res = await fetch(`${API_BASE}/api/gemini/keywords`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, context, customFocus })
    });
    return await res.json();
  },

  async geminiQueries(sessionId, context) {
    const res = await fetch(`${API_BASE}/api/gemini/queries`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, context })
    });
    return await res.json();
  },

  async geminiExplain(sessionId, videoResult, context) {
    const res = await fetch(`${API_BASE}/api/gemini/explain`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, videoResult, context })
    });
    return await res.json();
  },

  async geminiResearch(sessionId, context) {
    const res = await fetch(`${API_BASE}/api/gemini/research`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, context })
    });
    return await res.json();
  },

  async geminiSummarize(sessionId, context) {
    const res = await fetch(`${API_BASE}/api/gemini/summarize`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, context })
    });
    return await res.json();
  },

  async geminiIdeas(sessionId, context) {
    const res = await fetch(`${API_BASE}/api/gemini/ideas`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId, context })
    });
    return await res.json();
  },

  async geminiReset(sessionId) {
    const res = await fetch(`${API_BASE}/api/gemini/reset`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ sessionId })
    });
    return await res.json();
  }
};

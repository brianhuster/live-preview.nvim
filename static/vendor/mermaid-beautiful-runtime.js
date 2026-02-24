(function () {
  'use strict';

  const MERMAID_SELECTOR = '.language-mermaid';
  const FALLBACK_CLASS = 'livepreview-mermaid-fallback';
  const RENDERED_CLASS = 'livepreview-mermaid-rendered';
  const SOURCE_ATTR = 'livepreviewMermaidSource';
  const MODAL_ID = 'livepreview-mermaid-zoom-overlay';
  const MODAL_STYLE_ID = 'livepreview-mermaid-zoom-styles';
  const CONTROL_CONTAINER_CLASS = 'livepreview-mermaid-controls';
  const CONTROL_BUTTON_CLASS = 'livepreview-mermaid-zoom-btn';
  const ZOOM_CONTROL_CLASS = 'livepreview-mermaid-zoom-toolbar';
  const MODAL_CLOSE_CLASS = 'livepreview-mermaid-zoom-close';
  const MODAL_VIEWPORT_CLASS = 'livepreview-mermaid-zoom-viewport';
  const MODAL_BODY_CLASS = 'livepreview-mermaid-zoom-body';
  const MODAL_CONTENT_CLASS = 'livepreview-mermaid-zoom-content';

  const MODAL_STEP = 0.2;
  const MODAL_MIN_SCALE = 0.4;
  const MODAL_MAX_SCALE = 4;

  let activeDiagramNode = null;
  let activeContent = null;

  function injectStyles() {
    if (document.getElementById(MODAL_STYLE_ID)) {
      return;
    }

    const style = document.createElement('style');
    style.id = MODAL_STYLE_ID;
    style.textContent = `
      .${CONTROL_CONTAINER_CLASS} {
        position: absolute;
        inset-block-start: 6px;
        inset-inline-end: 6px;
        z-index: 20;
        pointer-events: auto;
        display: flex;
        gap: 6px;
      }

      .${CONTROL_BUTTON_CLASS} {
        appearance: none;
        border: 1px solid rgba(0,0,0,0.28);
        background: rgba(255,255,255,0.95);
        color: #0f172a;
        border-radius: 8px;
        width: 28px;
        height: 28px;
        padding: 0;
        cursor: pointer;
        font-size: 15px;
        line-height: 1;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 8px rgba(0,0,0,0.24);
      }

      .${CONTROL_BUTTON_CLASS}:hover,
      .${CONTROL_BUTTON_CLASS}:focus-visible {
        background: #eef2ff;
      }

      .${CONTROL_BUTTON_CLASS}:focus-visible {
        outline: 2px solid #6366f1;
        outline-offset: 2px;
      }

      .livepreview-mermaid-host {
        position: relative;
        display: inline-block;
      }

      #${MODAL_ID} {
        position: fixed;
        inset: 0;
        z-index: 9999;
        background: rgba(0,0,0,0.55);
        margin: 0;
        padding: 16px;
        display: none;
        align-items: center;
        justify-content: center;
      }

      #${MODAL_ID}.open { display: flex; }

      #${MODAL_ID} .${MODAL_VIEWPORT_CLASS} {
        position: relative;
        width: min(95vw, 1200px);
        height: min(95vh, 900px);
        display: flex;
        flex-direction: column;
        gap: 8px;
        padding: 10px;
        border-radius: 12px;
        border: 1px solid rgba(0,0,0,0.35);
        background: #fff;
        box-shadow: 0 16px 44px rgba(0,0,0,0.4);
      }

      #${MODAL_ID} .${MODAL_CLOSE_CLASS} {
        align-self: flex-end;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        border: 1px solid rgba(0,0,0,0.4);
        background: #fff;
        color: #111;
        cursor: pointer;
        font-size: 18px;
        line-height: 1;
        padding: 0;
      }

      #${MODAL_ID} .${ZOOM_CONTROL_CLASS} {
        display: inline-flex;
        align-self: center;
        gap: 6px;
      }

      #${MODAL_ID} .${ZOOM_CONTROL_CLASS} button {
        border: 1px solid rgba(0,0,0,0.3);
        background: #f4f4f5;
        color: #111;
        border-radius: 8px;
        min-width: 36px;
        height: 28px;
        padding: 0 8px;
        cursor: pointer;
      }

      #${MODAL_ID} .${MODAL_BODY_CLASS} {
        flex: 1;
        min-height: 0;
        overflow: auto;
        display: grid;
        place-items: center;
        background: #fff;
      }

      #${MODAL_ID} .${MODAL_CONTENT_CLASS} {
        width: fit-content;
        height: fit-content;
        transform: scale(1);
        transform-origin: center center;
        transition: transform 140ms ease;
      }

      #${MODAL_ID} .${MODAL_CONTENT_CLASS} > svg {
        width: 100%;
        height: auto;
        max-width: none;
        display: block;
      }

      @media (prefers-color-scheme: dark) {
        .${CONTROL_BUTTON_CLASS},
        #${MODAL_ID} .${MODAL_CLOSE_CLASS},
        #${MODAL_ID} .${ZOOM_CONTROL_CLASS} button {
          border-color: rgba(255,255,255,0.45);
          background: rgba(24,24,27,0.95);
          color: #f4f4f5;
        }

        #${MODAL_ID} .${MODAL_VIEWPORT_CLASS},
        #${MODAL_ID} .${MODAL_BODY_CLASS},
        #${MODAL_ID} .${MODAL_CONTENT_CLASS} > svg {
          background: #111827;
          color: #e5e7eb;
          border-color: rgba(255,255,255,0.4);
        }
      }
    `;
    document.head.appendChild(style);
  }

  function createZoomModal() {
    injectStyles();
    let modal = document.getElementById(MODAL_ID);
    if (modal) {
      return modal;
    }

    modal = document.createElement('div');
    modal.id = MODAL_ID;
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-hidden', 'true');
    modal.innerHTML = [
      '<div class="', MODAL_VIEWPORT_CLASS, '">',
      '<button type="button" class="', MODAL_CLOSE_CLASS, '" aria-label="Close">×</button>',
      '<div class="', ZOOM_CONTROL_CLASS, '">',
      '<button type="button" data-action="zoom-out" aria-label="Zoom out">−</button>',
      '<button type="button" data-action="reset" aria-label="Reset">Reset</button>',
      '<button type="button" data-action="zoom-in" aria-label="Zoom in">＋</button>',
      '</div>',
      '<div class="', MODAL_BODY_CLASS, '">',
      '<div class="', MODAL_CONTENT_CLASS, '"></div>',
      '</div>',
      '</div>'
    ].join('');

    const body = modal.querySelector(`.${MODAL_BODY_CLASS}`);
    const content = modal.querySelector(`.${MODAL_CONTENT_CLASS}`);
    const toolbar = modal.querySelector(`.${ZOOM_CONTROL_CLASS}`);
    const closeButton = modal.querySelector(`.${MODAL_CLOSE_CLASS}`);

    modal.addEventListener('click', function (event) {
      if (event.target === modal) {
        closeZoomModal();
      }
    });

    closeButton.addEventListener('click', function () {
      closeZoomModal();
    });

    toolbar.addEventListener('click', function (event) {
      if (!event.target || !event.target.dataset || !event.target.dataset.action) {
        return;
      }
      const action = event.target.dataset.action;
      const currentScale = parseFloat((activeContent && activeContent.dataset.scale) || '1');
      if (action === 'zoom-in') {
        setZoomScale(Math.min(MODAL_MAX_SCALE, currentScale + MODAL_STEP));
      } else if (action === 'zoom-out') {
        setZoomScale(Math.max(MODAL_MIN_SCALE, currentScale - MODAL_STEP));
      } else if (action === 'reset') {
        setZoomScale(1);
      }
    });

    modal.__livepreviewZoomBody = body;
    modal.__livepreviewZoomContent = content;

    if (!document.__livepreviewMermaidEscapeBound) {
      document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
          closeZoomModal();
        }
      }, { capture: true });
      document.__livepreviewMermaidEscapeBound = true;
    }

    document.body.appendChild(modal);
    return modal;
  }

  function closeZoomModal() {
    const modal = document.getElementById(MODAL_ID);
    if (!modal) {
      return;
    }

    modal.classList.remove('open');
    modal.setAttribute('aria-hidden', 'true');
    activeDiagramNode = null;
    activeContent = null;
  }

  function setZoomScale(scale) {
    const clampedScale = Math.max(MODAL_MIN_SCALE, Math.min(MODAL_MAX_SCALE, Number(scale) || 1));

    if (activeContent) {
      activeContent.dataset.scale = String(clampedScale);
      activeContent.style.transform = 'scale(' + clampedScale + ')';
    }

    if (activeDiagramNode) {
      activeDiagramNode.dataset.livepreviewMermaidZoomScale = String(clampedScale);
    }
  }

  function getZoomScaleFromDiagramNode(node) {
    if (!node || !node.dataset) {
      return 1;
    }

    const scale = Number(node.dataset.livepreviewMermaidZoomScale);
    if (!Number.isFinite(scale) || Number.isNaN(scale)) {
      return 1;
    }

    return Math.max(MODAL_MIN_SCALE, Math.min(MODAL_MAX_SCALE, scale));
  }

  function ensureModalOpen(node, sourceElement) {
    const modal = createZoomModal();
    const content = modal.__livepreviewZoomContent;

    if (!content) {
      return;
    }

    activeDiagramNode = node;
    activeContent = content;

    content.innerHTML = '';
    content.appendChild(sourceElement);

    setZoomScale(getZoomScaleFromDiagramNode(node));

    modal.classList.add('open');
    modal.setAttribute('aria-hidden', 'false');
  }

  function extractZoomContent(node) {
    const svg = getPrimaryDiagramSVG(node);
    if (svg) {
      const clone = svg.cloneNode(true);
      clone.removeAttribute('width');
      clone.removeAttribute('height');
      const wrapper = document.createElement('div');
      wrapper.appendChild(clone);
      wrapper.setAttribute('aria-label', 'Enlarged Mermaid diagram');
      return wrapper;
    }

    const source = readMermaidSource(node);
    const fallback = document.createElement('pre');
    fallback.className = 'livepreview-mermaid-zoom-fallback';
    fallback.textContent = source || '(mermaid source unavailable)';
    return fallback;
  }

  function openZoomModalFor(node) {
    const hostNode = getMermaidHost(node);
    if (!hostNode) {
      return;
    }

    const content = extractZoomContent(hostNode);
    ensureModalOpen(hostNode, content);
  }

  function getMermaidHost(node) {
    if (!node || !node.querySelectorAll) {
      return node;
    }

    if (node.tagName && node.tagName.toLowerCase() === 'code') {
      return node.closest('pre') || node;
    }

    return node;
  }

  function getPrimaryDiagramSVG(node) {
    if (!node || !node.querySelectorAll) {
      return null;
    }

    if (node.tagName && node.tagName.toLowerCase() === 'svg') {
      return node;
    }

    const candidates = Array.from(node.querySelectorAll('svg')).filter(function (svg) {
      const parent = svg.closest(`.${CONTROL_CONTAINER_CLASS}`);
      return parent === null;
    });
    return candidates[0] || null;
  }

  function createMagnifierControl(hostNode) {
    const host = getMermaidHost(hostNode);
    if (!host || host.querySelector(`.${CONTROL_CONTAINER_CLASS}`)) {
      return;
    }

    const hasDiagram = Boolean(getPrimaryDiagramSVG(host)) || Boolean(readMermaidSource(host));
    if (!hasDiagram) {
      return;
    }

    host.classList.add('livepreview-mermaid-host');

    const container = document.createElement('div');
    container.className = CONTROL_CONTAINER_CLASS;
    const button = document.createElement('button');
    button.type = 'button';
    button.className = CONTROL_BUTTON_CLASS;
    button.setAttribute('aria-label', 'Open mermaid diagram in magnifier');
    button.textContent = '⛶';
    button.title = 'Magnify diagram';

    button.addEventListener('click', function (event) {
      event.preventDefault();
      event.stopPropagation();
      openZoomModalFor(host);
    });

    container.appendChild(button);
    host.appendChild(container);
  }

  function addControlsToMermaidBlocks() {
    const blocks = Array.from(document.querySelectorAll(MERMAID_SELECTOR));
    blocks.forEach(function (block) {
      const host = getMermaidHost(block);
      if (!host) {
        return;
      }

      const oldContainer = host.querySelector(`.${CONTROL_CONTAINER_CLASS}`);
      if (oldContainer) {
        oldContainer.remove();
      }

      createMagnifierControl(block);
    });
  }

  function parseCssColor(value) {
    if (!value || typeof value !== 'string') return null;
    const color = value.trim();

    const hexMatch = color.match(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i);
    if (hexMatch) {
      const raw = hexMatch[1];
      if (raw.length === 3) {
        return {
          r: parseInt(raw[0] + raw[0], 16),
          g: parseInt(raw[1] + raw[1], 16),
          b: parseInt(raw[2] + raw[2], 16),
          a: 1,
        };
      }
      return {
        r: parseInt(raw.slice(0, 2), 16),
        g: parseInt(raw.slice(2, 4), 16),
        b: parseInt(raw.slice(4, 6), 16),
        a: 1,
      };
    }

    const rgbMatch = color.match(/^rgba?\(([^)]+)\)$/i);
    if (!rgbMatch) return null;

    const parts = rgbMatch[1].split(',').map(function (part) {
      return part.trim();
    });
    if (parts.length < 3) return null;

    const r = Number(parts[0]);
    const g = Number(parts[1]);
    const b = Number(parts[2]);
    const a = parts.length >= 4 ? Number(parts[3]) : 1;

    if ([r, g, b].some(function (channel) { return Number.isNaN(channel); })) return null;

    return {
      r: Math.max(0, Math.min(255, r)),
      g: Math.max(0, Math.min(255, g)),
      b: Math.max(0, Math.min(255, b)),
      a: Number.isNaN(a) ? 1 : Math.max(0, Math.min(1, a)),
    };
  }

  function isDark(color) {
    const parsed = parseCssColor(color);
    if (!parsed || parsed.a === 0) return false;
    const luminance = (0.2126 * parsed.r + 0.7152 * parsed.g + 0.0722 * parsed.b) / 255;
    return luminance < 0.5;
  }

  function getPalette() {
    const root = document.documentElement;
    const body = document.body || root;
    const bodyStyle = window.getComputedStyle(body);
    const rootStyle = window.getComputedStyle(root);

    let bg = bodyStyle.backgroundColor || rootStyle.backgroundColor || '#ffffff';
    const parsedBg = parseCssColor(bg);
    if (!parsedBg || parsedBg.a === 0) {
      bg = '#ffffff';
    }

    let fg = bodyStyle.color || rootStyle.color || '#111111';
    const parsedFg = parseCssColor(fg);
    if (!parsedFg || parsedFg.a === 0) {
      fg = '#111111';
    }

    return {
      bg,
      fg,
      dark: isDark(bg),
    };
  }

  function ensureMermaidInitialized(theme) {
    if (!window.mermaid || typeof window.mermaid.initialize !== 'function') return;
    window.mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'loose',
      theme: theme,
    });
  }

  function runMermaidFallback(selector, palette) {
    if (!window.mermaid || typeof window.mermaid.run !== 'function') return;
    ensureMermaidInitialized(palette.dark ? 'dark' : 'default');
    window.mermaid.run({ querySelector: selector });
  }

  function readMermaidSource(node) {
    if (node.dataset && node.dataset[SOURCE_ATTR]) {
      return node.dataset[SOURCE_ATTR];
    }
    return (node.textContent || '').trim();
  }

  function renderBeautiful(node, palette) {
    const beautiful = window.BeautifulMermaid;
    if (!beautiful || typeof beautiful.renderMermaidSVG !== 'function') {
      throw new Error('BeautifulMermaid renderer is unavailable');
    }

    const source = readMermaidSource(node);
    if (!source) {
      throw new Error('Empty Mermaid source block');
    }

    const svg = beautiful.renderMermaidSVG(source, {
      bg: palette.bg,
      fg: palette.fg,
    });

    if (typeof svg !== 'string' || svg.indexOf('<svg') === -1) {
      throw new Error('BeautifulMermaid did not return a valid SVG payload');
    }

    if (node.classList.contains(RENDERED_CLASS)) {
      node.innerHTML = svg;
      node.classList.remove(FALLBACK_CLASS);
      node.dataset[SOURCE_ATTR] = source;
      delete node.dataset.livepreviewMermaidZoomScale;
      return;
    }

    const wrapper = document.createElement('div');
    wrapper.className = `language-mermaid ${RENDERED_CLASS}`;
    wrapper.dataset[SOURCE_ATTR] = source;
    wrapper.dataset.livepreviewMermaidZoomScale = '1';
    wrapper.innerHTML = svg;

    const pre = node.tagName === 'CODE' ? node.closest('pre') : null;
    const target = pre || node;
    target.replaceWith(wrapper);
  }

  function scheduleControlRefresh() {
    if (typeof requestAnimationFrame === 'function') {
      requestAnimationFrame(addControlsToMermaidBlocks);
      return;
    }

    setTimeout(addControlsToMermaidBlocks, 0);
  }

  function renderAllMermaidBlocks() {
    const blocks = Array.from(document.querySelectorAll(MERMAID_SELECTOR));
    if (!blocks.length) return;

    const palette = getPalette();
    const beautifulReady = !!(
      window.BeautifulMermaid && typeof window.BeautifulMermaid.renderMermaidSVG === 'function'
    );

    blocks.forEach(function (block) {
      const host = getMermaidHost(block);
      if (!host) return;
      const existing = host.querySelector(`.${CONTROL_CONTAINER_CLASS}`);
      if (existing) {
        existing.remove();
      }
    });

    if (!beautifulReady) {
      runMermaidFallback(MERMAID_SELECTOR, palette);
      scheduleControlRefresh();
      return;
    }

    let fallbackNeeded = false;
    blocks.forEach(function (block) {
      try {
        renderBeautiful(block, palette);
      } catch (error) {
        block.classList.add(FALLBACK_CLASS);
        fallbackNeeded = true;
        console.warn('[livepreview] beautiful-mermaid failed; using mermaid fallback for one block', error);
      }
    });

    if (fallbackNeeded) {
      runMermaidFallback(`.${FALLBACK_CLASS}`, palette);
    }

    scheduleControlRefresh();
  }

  function start() {
    renderAllMermaidBlocks();
    if (window.matchMedia) {
      const media = window.matchMedia('(prefers-color-scheme: dark)');
      if (typeof media.addEventListener === 'function') {
        media.addEventListener('change', renderAllMermaidBlocks);
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true });
  } else {
    start();
  }
})();

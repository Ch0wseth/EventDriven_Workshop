// ============================================
// MODULE CONFIGURATION
// ============================================
const modules = [
    { id: '00-introduction', icon: '📖', title: 'Introduction', file: '/docs/00-introduction.md' },
    { id: '01-azure-event-services', icon: '☁️', title: 'Services Azure Event-Driven', file: '/docs/01-azure-event-services.md' },
    { id: '02-event-hubs', icon: '⚡', title: 'Déploiement de l\'Architecture', file: '/docs/02-event-hubs.md' },
    { id: '03-event-hubs-advanced', icon: '🚀', title: 'Event Hubs - Avancé', file: '/docs/03-event-hubs-advanced.md' },
    { id: '04-event-grid', icon: '🔔', title: 'Event Grid', file: '/docs/04-event-grid.md' },
    { id: '06-hands-on-lab', icon: '🛠️', title: 'Lab Final - Pipeline Complet', file: '/docs/06-hands-on-lab.md' },
    { id: '07-foundry-event-driven', icon: '🤖', title: 'Foundry Agents + Event-Driven', file: '/docs/07-foundry-event-driven.md', badge: 'NEW' },
];

// ============================================
// STATE MANAGEMENT
// ============================================
let currentModule = null;
let completedModules = [];
let darkMode = localStorage.getItem('darkMode') === 'true';

// ============================================
// INITIALIZATION
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
    renderModuleNav();
    loadCompletedModules();
    updateProgress();
    initializeDarkMode();
    initializeMermaid();
    
    // Check if there's a hash in URL
    const hash = window.location.hash.substring(1);
    if (hash && modules.find(m => m.id === hash)) {
        loadModule(hash);
    }
});

// ============================================
// APP INITIALIZATION
// ============================================
function initializeApp() {
    console.log('🚀 Event-Driven Workshop Loaded');
    
    // Configure marked.js
    marked.setOptions({
        breaks: true,
        gfm: true,
        highlight: function(code, lang) {
            if (lang && hljs.getLanguage(lang)) {
                try {
                    return hljs.highlight(code, { language: lang }).value;
                } catch (err) {}
            }
            return hljs.highlightAuto(code).value;
        }
    });
}

// ============================================
// MODULE NAVIGATION
// ============================================
function renderModuleNav() {
    const nav = document.getElementById('moduleNav');
    
    modules.forEach(module => {
        const item = document.createElement('div');
        item.className = 'nav-item';
        
        const link = document.createElement('a');
        link.className = 'nav-link';
        link.href = `#${module.id}`;
        link.onclick = (e) => {
            e.preventDefault();
            loadModule(module.id);
        };
        
        link.innerHTML = `
            <span class="nav-link-icon">${module.icon}</span>
            <span>${module.title}</span>
            ${module.badge ? `<span class="nav-link-badge">${module.badge}</span>` : ''}
        `;
        
        item.appendChild(link);
        nav.appendChild(item);
    });
}

// ============================================
// MODULE LOADING
// ============================================
async function loadModule(moduleId) {
    const module = modules.find(m => m.id === moduleId);
    if (!module) return;
    
    currentModule = moduleId;
    
    // Update URL
    window.location.hash = moduleId;
    
    // Update UI
    document.getElementById('homePage').style.display = 'none';
    document.getElementById('moduleContent').style.display = 'block';
    
    // Update active nav
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`a[href="#${moduleId}"]`)?.classList.add('active');
    
    // Load content
    try {
        const response = await fetch(module.file);
        if (!response.ok) throw new Error('Failed to load module');
        
        const markdown = await response.text();
        const html = marked.parse(markdown);
        
        document.getElementById('moduleContent').innerHTML = html;
        
        // Highlight code blocks
        document.querySelectorAll('pre code').forEach(block => {
            hljs.highlightBlock(block);
            addCopyButton(block);
        });
        
        // Render mermaid diagrams
        renderMermaidDiagrams();

        // Intercept internal .md links to load modules via the SPA
        document.querySelectorAll('#moduleContent a[href]').forEach(a => {
            const href = a.getAttribute('href');
            if (href && href.endsWith('.md') && !href.startsWith('http')) {
                const filename = href.split('/').pop().replace('.md', '');
                const target = modules.find(m => m.id === filename);
                if (target) {
                    a.href = `#${target.id}`;
                    a.onclick = (e) => { e.preventDefault(); loadModule(target.id); };
                }
            }
        });
        
        // Scroll to top
        window.scrollTo(0, 0);
        
        // Mark as completed
        markModuleCompleted(moduleId);
        
    } catch (error) {
        console.error('Error loading module:', error);
        document.getElementById('moduleContent').innerHTML = `
            <div style="text-align: center; padding: 60px 20px;">
                <h2>❌ Erreur de chargement</h2>
                <p>Impossible de charger le module. Vérifiez que les fichiers sont présents dans <code>../docs/</code></p>
                <button class="btn btn-primary" onclick="showHome()">Retour à l'accueil</button>
            </div>
        `;
    }
}

// ============================================
// COPY CODE BUTTON
// ============================================
function addCopyButton(codeBlock) {
    const button = document.createElement('button');
    button.className = 'copy-code-btn';
    button.textContent = '📋 Copy';
    button.style.cssText = `
        position: absolute;
        top: 8px;
        right: 8px;
        padding: 4px 12px;
        background: var(--primary);
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.85rem;
        opacity: 0;
        transition: opacity 0.3s;
    `;
    
    const pre = codeBlock.parentElement;
    pre.style.position = 'relative';
    pre.appendChild(button);
    
    pre.addEventListener('mouseenter', () => {
        button.style.opacity = '1';
    });
    
    pre.addEventListener('mouseleave', () => {
        button.style.opacity = '0';
    });
    
    button.addEventListener('click', () => {
        navigator.clipboard.writeText(codeBlock.textContent);
        button.textContent = '✓ Copied!';
        setTimeout(() => {
            button.textContent = '📋 Copy';
        }, 2000);
    });
}

// ============================================
// MERMAID DIAGRAMS
// ============================================
function initializeMermaid() {
    mermaid.initialize({
        startOnLoad: false,
        theme: darkMode ? 'dark' : 'default',
        securityLevel: 'loose',
    });
}

function renderMermaidDiagrams() {
    const mermaidBlocks = document.querySelectorAll('code.language-mermaid');
    mermaidBlocks.forEach((block, index) => {
        const code = block.textContent;
        const div = document.createElement('div');
        div.className = 'mermaid';
        div.textContent = code;
        block.parentElement.replaceWith(div);
    });
    
    mermaid.run();
}

// ============================================
// PROGRESS TRACKING
// ============================================
function loadCompletedModules() {
    const saved = localStorage.getItem('completedModules');
    completedModules = saved ? JSON.parse(saved) : [];
}

function markModuleCompleted(moduleId) {
    if (!completedModules.includes(moduleId)) {
        completedModules.push(moduleId);
        localStorage.setItem('completedModules', JSON.stringify(completedModules));
        updateProgress();
    }
}

function updateProgress() {
    const progress = (completedModules.length / modules.length) * 100;
    document.getElementById('progressBar').style.width = `${progress}%`;
    document.getElementById('progressText').textContent = `${completedModules.length}/${modules.length} modules`;
}

// ============================================
// DARK MODE
// ============================================
function initializeDarkMode() {
    if (darkMode) {
        document.documentElement.setAttribute('data-theme', 'dark');
        document.getElementById('darkModeToggle').textContent = '☀️';
    }
    
    document.getElementById('darkModeToggle').addEventListener('click', toggleDarkMode);
}

function toggleDarkMode() {
    darkMode = !darkMode;
    localStorage.setItem('darkMode', darkMode);
    
    if (darkMode) {
        document.documentElement.setAttribute('data-theme', 'dark');
        document.getElementById('darkModeToggle').textContent = '☀️';
    } else {
        document.documentElement.removeAttribute('data-theme');
        document.getElementById('darkModeToggle').textContent = '🌙';
    }
    
    // Reinitialize mermaid with new theme
    initializeMermaid();
    if (currentModule) {
        renderMermaidDiagrams();
    }
}

// ============================================
// HOME NAVIGATION
// ============================================
function showHome() {
    currentModule = null;
    window.location.hash = '';
    
    document.getElementById('homePage').style.display = 'block';
    document.getElementById('moduleContent').style.display = 'none';
    
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    
    window.scrollTo(0, 0);
}

// Handle browser back/forward
window.addEventListener('hashchange', () => {
    const hash = window.location.hash.substring(1);
    if (hash && modules.find(m => m.id === hash)) {
        loadModule(hash);
    } else {
        showHome();
    }
});

// ============================================
// EXPOSE FUNCTIONS GLOBALLY
// ============================================
window.loadModule = loadModule;
window.showHome = showHome;

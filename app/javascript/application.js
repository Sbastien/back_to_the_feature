// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

/**
 * Application JavaScript Module
 * Modern ES6+ patterns with proper error handling and event management
 */
class AppController {
  constructor() {
    this.elements = {};
    this.handlers = new Map();
    this.isDevelopment = window.location.hostname === 'localhost';

    this.init();
  }

  /**
   * Initialize the application
   */
  init() {
    this.log('Initializing App Controller...');
    this.bindElements();
    this.setupEventListeners();
    this.initializeComponents();
  }

  /**
   * Bind DOM elements
   */
  bindElements() {
    this.elements = {
      html: document.documentElement,
      themeToggle: document.getElementById('theme-toggle'),
      languageToggle: document.getElementById('language-toggle'),
      currentLanguage: document.getElementById('current-language'),
      csrfToken: document.querySelector('meta[name="csrf-token"]')
    };

    this.log('Elements bound:', {
      themeToggle: !!this.elements.themeToggle,
      languageToggle: !!this.elements.languageToggle,
      currentLanguage: !!this.elements.currentLanguage,
      csrfToken: !!this.elements.csrfToken
    });
  }

  /**
   * Setup event listeners with proper cleanup
   */
  setupEventListeners() {
    // Clean up existing listeners
    this.cleanupEventListeners();

    // Theme toggle
    if (this.elements.themeToggle) {
      const themeHandler = (e) => this.handleThemeToggle(e);
      this.elements.themeToggle.addEventListener('click', themeHandler);
      this.handlers.set('theme', themeHandler);
    }

    // Language toggle
    if (this.elements.languageToggle && this.elements.currentLanguage) {
      const languageHandler = (e) => this.handleLanguageToggle(e);
      this.elements.languageToggle.addEventListener('click', languageHandler);
      this.handlers.set('language', languageHandler);
    }

    // Flash message auto-hide
    this.setupFlashMessages();
  }

  /**
   * Clean up existing event listeners
   */
  cleanupEventListeners() {
    this.handlers.forEach((handler, key) => {
      const element = key === 'theme' ? this.elements.themeToggle : this.elements.languageToggle;
      if (element) {
        element.removeEventListener('click', handler);
      }
    });
    this.handlers.clear();
  }

  /**
   * Initialize component-specific functionality
   */
  initializeComponents() {
    this.setupFormEnhancements();
    this.setupCardHoverEffects();
    this.setupSmoothScrolling();
    this.setupProgressiveEnhancements();
    this.log('Components initialized successfully');
  }

  /**
   * Setup form enhancements for better UX
   */
  setupFormEnhancements() {
    // Add floating labels for inputs
    const inputs = document.querySelectorAll('.form-input, .form-textarea');
    inputs.forEach(input => {
      this.setupFloatingLabel(input);
    });

    // Add real-time validation feedback
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      this.setupFormValidation(form);
    });
  }

  /**
   * Setup floating label behavior
   */
  setupFloatingLabel(input) {
    const updateLabel = () => {
      const label = input.parentNode.querySelector('.form-label');
      if (label) {
        if (input.value || input === document.activeElement) {
          label.style.transform = 'translateY(-1.5rem) scale(0.9)';
          label.style.color = 'var(--color-primary-600)';
        } else {
          label.style.transform = 'translateY(0) scale(1)';
          label.style.color = 'var(--color-neutral-600)';
        }
      }
    };

    input.addEventListener('focus', updateLabel);
    input.addEventListener('blur', updateLabel);
    input.addEventListener('input', updateLabel);

    // Initial state
    updateLabel();
  }

  /**
   * Setup form validation with better UX
   */
  setupFormValidation(form) {
    const inputs = form.querySelectorAll('.form-input, .form-textarea');

    inputs.forEach(input => {
      input.addEventListener('invalid', (e) => {
        e.preventDefault();
        this.showValidationError(input, input.validationMessage);
      });

      input.addEventListener('input', () => {
        if (input.validity.valid) {
          this.clearValidationError(input);
        }
      });
    });
  }

  /**
   * Show validation error with animation
   */
  showValidationError(input, message) {
    input.classList.add('error');

    let errorDiv = input.parentNode.querySelector('.form-error');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.className = 'form-error';
      errorDiv.innerHTML = `
        <svg style="width: 1rem; height: 1rem;" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
        </svg>
        <span></span>
      `;
      input.parentNode.appendChild(errorDiv);
    }

    errorDiv.querySelector('span').textContent = message;
    errorDiv.style.opacity = '0';
    errorDiv.style.transform = 'translateY(-0.5rem)';

    requestAnimationFrame(() => {
      errorDiv.style.transition = 'all 0.25s ease';
      errorDiv.style.opacity = '1';
      errorDiv.style.transform = 'translateY(0)';
    });
  }

  /**
   * Clear validation error with animation
   */
  clearValidationError(input) {
    input.classList.remove('error');
    const errorDiv = input.parentNode.querySelector('.form-error');

    if (errorDiv) {
      errorDiv.style.opacity = '0';
      errorDiv.style.transform = 'translateY(-0.5rem)';

      setTimeout(() => {
        if (errorDiv.parentNode) {
          errorDiv.parentNode.removeChild(errorDiv);
        }
      }, 250);
    }
  }

  /**
   * Setup card hover effects
   */
  setupCardHoverEffects() {
    const cards = document.querySelectorAll('.feature-card, .card');

    cards.forEach(card => {
      card.addEventListener('mouseenter', () => {
        card.style.transform = 'translateY(-2px)';
        card.style.boxShadow = 'var(--shadow-lg)';
      });

      card.addEventListener('mouseleave', () => {
        card.style.transform = 'translateY(0)';
        card.style.boxShadow = 'var(--shadow-sm)';
      });
    });
  }

  /**
   * Setup smooth scrolling for anchor links
   */
  setupSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');

    links.forEach(link => {
      link.addEventListener('click', (e) => {
        const targetId = link.getAttribute('href').substring(1);
        const targetElement = document.getElementById(targetId);

        if (targetElement) {
          e.preventDefault();
          targetElement.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  }

  /**
   * Setup progressive enhancements
   */
  setupProgressiveEnhancements() {
    // Add intersection observer for animations
    if ('IntersectionObserver' in window) {
      this.setupScrollAnimations();
    }

    // Add loading states for forms
    this.setupLoadingStates();

    // Add keyboard navigation improvements
    this.setupKeyboardNavigation();
  }

  /**
   * Setup scroll-triggered animations
   */
  setupScrollAnimations() {
    const animatedElements = document.querySelectorAll('.animate-fade-in, .animate-slide-up');

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    });

    animatedElements.forEach(el => {
      el.style.opacity = '0';
      if (el.classList.contains('animate-slide-up')) {
        el.style.transform = 'translateY(2rem)';
      }
      el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
      observer.observe(el);
    });
  }

  /**
   * Setup loading states for better perceived performance
   */
  setupLoadingStates() {
    const forms = document.querySelectorAll('form');

    forms.forEach(form => {
      form.addEventListener('submit', (e) => {
        const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');

        if (submitBtn && !form.hasAttribute('data-no-loading')) {
          submitBtn.style.opacity = '0.7';
          submitBtn.style.cursor = 'not-allowed';
          submitBtn.value = submitBtn.value.replace(/^(.+)$/, '$1...');

          // Prevent double submission
          submitBtn.disabled = true;
        }
      });
    });
  }

  /**
   * Setup keyboard navigation improvements
   */
  setupKeyboardNavigation() {
    // Add visible focus indicators
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        document.body.classList.add('keyboard-navigation');
      }
    });

    document.addEventListener('mousedown', () => {
      document.body.classList.remove('keyboard-navigation');
    });

    // Add escape key handler for modals and overlays
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        const activeModal = document.querySelector('.modal.active');
        const activeDropdown = document.querySelector('.dropdown.active');

        if (activeModal) {
          this.closeModal(activeModal);
        } else if (activeDropdown) {
          this.closeDropdown(activeDropdown);
        }
      }
    });
  }

  /**
   * Handle theme toggle with error recovery
   */
  async handleThemeToggle(event) {
    event.preventDefault();
    event.stopPropagation();

    try {
      const currentTheme = this.elements.html.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

      this.log(`Switching theme from ${currentTheme} to ${newTheme}`);

      // Update DOM immediately for better UX
      this.updateThemeDOM(newTheme);

      // Save preference to server
      await this.saveThemePreference(newTheme);

    } catch (error) {
      this.handleError('Theme toggle failed', error);
      // Revert DOM changes on error
      const previousTheme = this.elements.html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      this.updateThemeDOM(previousTheme);
    }
  }

  /**
   * Update theme in DOM
   */
  updateThemeDOM(theme) {
    const currentTheme = this.elements.html.getAttribute('data-theme');
    this.elements.html.classList.remove(currentTheme);
    this.elements.html.classList.add(theme);
    this.elements.html.setAttribute('data-theme', theme);
  }

  /**
   * Save theme preference to server
   */
  async saveThemePreference(theme) {
    if (!this.elements.csrfToken) {
      throw new Error('CSRF token not found');
    }

    const response = await fetch('/preferences/theme', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.elements.csrfToken.getAttribute('content')
      },
      body: JSON.stringify({ theme })
    });

    if (!response.ok) {
      throw new Error(`Server responded with ${response.status}`);
    }

    this.log('Theme preference saved successfully');
  }

  /**
   * Handle language toggle with error recovery
   */
  async handleLanguageToggle(event) {
    event.preventDefault();
    event.stopPropagation();

    try {
      const currentLocale = this.elements.currentLanguage.textContent.toLowerCase();
      const newLocale = currentLocale === 'en' ? 'fr' : 'en';

      this.log(`Switching language from ${currentLocale} to ${newLocale}`);

      // Update display immediately
      this.elements.currentLanguage.textContent = newLocale.toUpperCase();

      // Save preference and reload
      await this.saveLocalePreference(newLocale);

    } catch (error) {
      this.handleError('Language toggle failed', error);
      // Revert display on error
      const previousLocale = this.elements.currentLanguage.textContent.toLowerCase() === 'en' ? 'fr' : 'en';
      this.elements.currentLanguage.textContent = previousLocale.toUpperCase();
    }
  }

  /**
   * Save locale preference to server
   */
  async saveLocalePreference(locale) {
    if (!this.elements.csrfToken) {
      throw new Error('CSRF token not found');
    }

    const response = await fetch('/preferences/locale', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.elements.csrfToken.getAttribute('content')
      },
      body: JSON.stringify({ locale })
    });

    if (!response.ok) {
      throw new Error(`Server responded with ${response.status}`);
    }

    this.log('Locale preference saved, reloading page...');
    window.location.reload();
  }

  /**
   * Setup flash message auto-hide functionality
   */
  setupFlashMessages() {
    const flashMessages = document.querySelectorAll('.flash');
    flashMessages.forEach(flash => {
      // Auto-hide after 5 seconds
      setTimeout(() => {
        if (flash.parentNode) {
          flash.style.opacity = '0';
          flash.style.transform = 'translateX(100%)';
          setTimeout(() => {
            flash.remove();
          }, 300);
        }
      }, 5000);

      // Click to dismiss
      flash.addEventListener('click', () => {
        flash.style.opacity = '0';
        flash.style.transform = 'translateX(100%)';
        setTimeout(() => {
          flash.remove();
        }, 300);
      });
    });
  }

  /**
   * Centralized error handling
   */
  handleError(message, error) {
    console.error(`[App Error] ${message}:`, error);

    // In development, show more details
    if (this.isDevelopment) {
      console.error('Stack trace:', error.stack);
    }
  }

  /**
   * Centralized logging
   */
  log(...args) {
    if (this.isDevelopment) {
      console.log('[App]', ...args);
    }
  }

  /**
   * Reinitialize after navigation
   */
  reinitialize() {
    this.log('Reinitializing after navigation...');
    this.bindElements();
    this.setupEventListeners();
    this.initializeComponents();
  }
}

// Global app instance
let appController;

/**
 * Initialize application
 */
function initializeApp() {
  if (appController) {
    appController.reinitialize();
  } else {
    appController = new AppController();
  }
}

// Event listeners for various page load scenarios
document.addEventListener('DOMContentLoaded', initializeApp);
document.addEventListener('turbo:load', initializeApp);
document.addEventListener('turbo:render', initializeApp);
document.addEventListener('turbolinks:load', initializeApp); // Fallback

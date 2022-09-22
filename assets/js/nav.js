(function () {

  // Requires accompanying CSS rules, based on classes on main container
  // (body) that style header, menu and trigger button.
  // Container classes used: .with-expandable-nav, .with-expanded-nav

  class NavTrigger {
    constructor({ triggerTemplateSelector, onTriggerClick }) {
      this.onTriggerClick = onTriggerClick;
      this.triggerTemplate = document.querySelector(`${triggerTemplateSelector}`);
      this.triggerEl = document.importNode(this.triggerTemplate.content, true);
    }

    render() {
      const wrapper = this.triggerEl.children[0];
      wrapper.addEventListener('click', this.onTriggerClick);
      return wrapper;
    }
  }

  class ExpandableContainer {
    constructor({
        containerEl,
        headerEl,
        mainEl,
        footerEl,
        expandableNavEl, priorityNavEl,
        expandableHtmlClass, expandedHtmlClass }) {

      this.toggle = this.toggle.bind(this);

      this.expandedHtmlClass = expandedHtmlClass;

      this.containerEl = containerEl;
      this.headerEl = headerEl;
      this.mainEl = mainEl;
      this.footerEl = footerEl;
      this.expandableNavEl = expandableNavEl;
      this.priorityNavEl = priorityNavEl;

      this.expandableNavBottomOffset = 20;
      this.containerEl.classList.add(expandableHtmlClass);

      this.expanded = false;
      this.animationTimeout = undefined;
    }

    toggle() {
      this.expanded = !this.expanded;
      this.update();
    }

    update() {
      if (this.expanded) {
        window.clearTimeout(this.animationTimeout);

        // Hold main position
        const mainTopOffset =
          this.mainEl.getBoundingClientRect().top +
          document.documentElement.scrollTop -
          (document.documentElement.clientTop || document.body.clientTop || 0);
        this.mainEl.style.marginTop = `${mainTopOffset}px`;

        this.containerEl.classList.add(this.expandedHtmlClass);

        const expH = this.expandableNavEl ?
          this.expandableNavEl.getBoundingClientRect().height :
          0;

        const prioH = this.priorityNavEl ?
          this.priorityNavEl.getBoundingClientRect().height :
          0;

        const heightDifference = expH - prioH + this.expandableNavBottomOffset;

        this.headerEl.style.paddingBottom = `${heightDifference}px`;
        this.headerEl.style.zIndex = '2';
        this.headerEl.style.position = 'absolute';
        this.headerEl.style.top = '0px';
        this.headerEl.style.left = '0px';
        this.headerEl.style.right = '0px';

      } else {
        this.containerEl.classList.remove(this.expandedHtmlClass);
        this.headerEl.style.removeProperty('padding-bottom');

        window.clearTimeout(this.animationTimeout);

        this.animationTimeout = window.setTimeout(() => {
          this.mainEl.style.removeProperty('margin-top');
          this.headerEl.style.removeProperty('z-index');
          this.headerEl.style.removeProperty('position');
        }, 1000);
      }
    }
  }

  const body = document.querySelector('body');
  const headerEl = document.querySelector('body > header');
  const expandableNavEl = headerEl.querySelector('nav.expandable-nav');
  const committeeMenuEl = headerEl.querySelector('.committee-widget .committee-menu');

  if (expandableNavEl || committeeMenuEl) {

    const container = new ExpandableContainer({
      containerEl: body,
      expandableHtmlClass: 'with-expandable-nav',
      expandedHtmlClass: 'with-expanded-nav',
      headerEl: headerEl,
      footerEl: document.querySelector('body > footer'),
      mainEl: document.querySelector('body > main'),
      expandableNavEl: expandableNavEl,
      priorityNavEl: headerEl.querySelector('nav.priority-nav'),
    });

    const trigger = new NavTrigger({
      triggerTemplateSelector: '#expandableNavTrigger',
      onTriggerClick: container.toggle,
    });

    headerEl.appendChild(trigger.render());

  }

}());

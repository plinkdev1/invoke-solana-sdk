import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    {
      type: 'doc',
      id: 'getting-started',
      label: 'Getting Started',
    },
    {
      type: 'doc',
      id: 'core-concepts',
      label: 'Core Concepts',
    },
    {
      type: 'doc',
      id: 'api-reference',
      label: 'API Reference',
    },
    {
      type: 'doc',
      id: 'auth-cache',
      label: 'Auth Cache Guide',
    },
    {
      type: 'doc',
      id: 'session-management',
      label: 'Session Management',
    },
    {
      type: 'doc',
      id: 'migration-guide',
      label: 'Migration Guide',
    },
  ],
};

export default sidebars;

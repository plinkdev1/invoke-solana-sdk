import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Invoke SDK',
  tagline: 'Solana Mobile Wallet Adapter for Godot Engine',
  favicon: 'img/favicon.ico',

  url: 'https://invoke-sdk.dev',
  baseUrl: '/',

  organizationName: 'plinkdev1',
  projectName: 'invoke-solana-sdk',

  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl: 'https://github.com/plinkdev1/invoke-solana-sdk/tree/main/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'Invoke SDK',
      logo: {
        alt: 'Invoke SDK Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          to: '/docs/api-reference',
          label: 'API',
          position: 'left',
        },
        {
          href: 'https://github.com/plinkdev1/invoke-solana-sdk',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Getting Started', to: '/docs/getting-started' },
            { label: 'API Reference', to: '/docs/api-reference' },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/plinkdev1/invoke-solana-sdk',
            },
            {
              label: 'Solana Mobile',
              href: 'https://solanamobile.com',
            },
          ],
        },
      ],
      copyright: 'Copyright © 2026 Francisco (Franny). Built with Docusaurus.',
    },
    prism: {
      theme: prismThemes.dracula,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['kotlin', 'bash', 'json'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;


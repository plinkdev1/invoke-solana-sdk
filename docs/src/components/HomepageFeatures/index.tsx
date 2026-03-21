import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Drop-in Godot Plugin',
    description: (
      <>
        Add Invoke to any Godot 4.x Android project in minutes.
        Copy the addon folder, enable the plugin, add one AutoLoad —
        and your game can talk to Phantom, Backpack, and Solflare.
      </>
    ),
  },
  {
    title: 'Auth Token Cache',
    description: (
      <>
        Users approve your app once. Every subsequent launch reconnects
        silently in the background — no wallet popup. Powered by
        Android EncryptedSharedPreferences with three swappable backends.
      </>
    ),
  },
  {
    title: 'Full MWA API Parity',
    description: (
      <>
        Every method from the React Native MWA SDK is available in GDScript:
        authorize, reauthorize, deauthorize, sign transactions,
        sign and send, sign messages, and get capabilities.
      </>
    ),
  },
];

function Feature({title, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center padding-horiz--md" style={{paddingTop: '2rem'}}>
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

//import js from '@eslint/js';
import parser from '@typescript-eslint/parser';

export default [
  {
    // The '.next/**' directory has been removed from ignores.
    ignores: ['node_modules/**', 'cache/**', 'test-results/**', 'coverage/**'],
  },
  // For a good set of baseline rules, you may want to uncomment the following line.
  // You would also need to uncomment the `import js from '@eslint/js';` at the top.
  // js.configs.recommended,
  {
    name: 'ESLint Config - base',
    languageOptions: {
      parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          // JSX support is kept in case you are using React without Next.js
          jsx: true,
        },
      },
    },
    // The files pattern is kept as it's generic.
    files: ['**/*.{js,mjs,cjs,ts,jsx,tsx}'],

    // The @next/next plugin and its associated rules have been removed.
    // You can add other plugins or define your own rules here.
    plugins: {},
    rules: {},
  },
];

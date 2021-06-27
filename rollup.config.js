import commonjs from '@rollup/plugin-commonjs'
import { nodeResolve } from '@rollup/plugin-node-resolve'
import pkg from './package.json'

const config = {
  input: 'lib/index.js',
  output: [
    {
      file: pkg.umd,
      format: 'umd',
      name: 'graphlib',
    },
    {
      file: pkg.module,
      format: 'esm',
      entryFileNames: 'graphlib.js',
    },
  ],
  plugins: [
    commonjs(),
    nodeResolve(),
  ],
}

export default config

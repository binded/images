import test from 'tape'
import initApp from '../src'

const { app } = initApp()

test('random test', (t) => {
  t.deepEqual(app.get('config'), {
    port: 5000,
  })
  t.end()
})

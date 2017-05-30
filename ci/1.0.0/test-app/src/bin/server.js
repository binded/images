import initApp from '../'

const { start } = initApp()

const main = async () => {
  try {
    const server = await start()
    const { address, port } = server.address()
    console.log(`Server listening on ${address}:${port}`)
  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}

main()

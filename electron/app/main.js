const electron = require('electron')
const path = require('path')

const {
  app,
  BrowserWindow,
  globalShortcut,
  protocol,
  screen
} = electron

const {
  SHOW_DEVTOOLS = false,
  APP_URL = 'http://server:8080'
} = process.env

// ================== Websocket stuff ==================

protocol.registerSchemesAsPrivileged([
  {
    scheme: 'http',
    privileges: {
      bypassCSP: true,
      secure: true,
      supportFetchAPI: true,
      corsEnabled: true
    }
  }
])

boot()

const electronOptions = {
  x: 0,
  y: 0,
  frame: false,
  kiosk: false,
  backgroundColor: '#FFF',
  webPreferences: {
    devTools: true,
    disableDialogs: true,
    spellcheck: false,
    enableWebSQL: false,
    nodeIntegrationInSubFrames: true
  },
}

function boot () {

  app.whenReady().then(() => {

    const { width, height } = screen.getPrimaryDisplay().workAreaSize

    electronOptions.width = width
    electronOptions.height = height

    process.on('unhandledRejection', (err) => {

      // eslint-disable-next-line no-console
      console.log('ELECTRON: unhandledRejection', err.message)

    })

    process.on('uncaughtException', (err) => {

      // eslint-disable-next-line no-console
      console.log('ELECTRON: uncaughtException', err.message)

    })

    globalShortcut.register('Control+Shift+I', () => false)
    globalShortcut.register('Control+q', () => false)

    const appWindow = new BrowserWindow(electronOptions)

    if (SHOW_DEVTOOLS)
      appWindow.webContents.openDevTools()

    appWindow.loadURL(APP_URL)

    appWindow.webContents.on('did-finish-load', () => {
      setTimeout(() => {

        appWindow.show()

      }, 300)
    })
  })
}

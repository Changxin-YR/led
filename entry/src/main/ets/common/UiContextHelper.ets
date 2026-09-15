import { UIContext } from '@kit.ArkUI'

export class UiContextHelper {
  static requireHostContext(uiContext: UIContext): Context {
    const context = uiContext.getHostContext()
    if (!context) throw new Error('Host context is unavailable')
    return context
  }

  static showToast(uiContext: UIContext, message: string): void {
    try {
      uiContext.getPromptAction().showToast({ message: message })
    } catch (error) {
      console.error(`UiContextHelper: failed to show toast: ${JSON.stringify(error)}`)
    }
  }

  static back(uiContext: UIContext): void {
    try {
      uiContext.getRouter().back()
    } catch (error) {
      console.error(`UiContextHelper: failed to navigate back: ${JSON.stringify(error)}`)
    }
  }

  static async pushUrl(uiContext: UIContext, url: string, params?: Object): Promise<void> {
    try {
      if (params) {
        await uiContext.getRouter().pushUrl({ url: url, params: params })
      } else {
        await uiContext.getRouter().pushUrl({ url: url })
      }
    } catch (error) {
      throw new Error(`Unable to open ${url}: ${JSON.stringify(error)}`)
    }
  }
}

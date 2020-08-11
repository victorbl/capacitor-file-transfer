declare module '@capacitor/core' {
  interface PluginRegistry {
    FileTransfer: FileTransferPlugin;
  }
}

export interface FileTransferPlugin {
  downloadRelative(options: {source: string, target: string, refresh: boolean}): Promise<{url: string, path: string}>;
  downloadAbsolute(options: {source: string, target: string, refresh: boolean}): Promise<{url: string, path: string}>;
}

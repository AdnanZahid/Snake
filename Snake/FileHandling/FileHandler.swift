//
//  FileHandler.swift
//  Rocket
//
//  Created by Adnan Zahid on 23/05/2020.
//  Copyright © 2020 Rocket. All rights reserved.
//

import Foundation

class FileHandler {

  static func contents(of fileName: String) -> String {
    var contents = ""
    do { contents = try String(contentsOfFile: fileName) }
    catch {}
    return contents
  }

  static func write(to fileName: String, content: String) {
    if let documentsDirectory = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)
      .last?.appendingPathComponent("Projects/Snake/Snake/FileHandling") {
      let fileURL = documentsDirectory.appendingPathComponent(fileName)
      do {
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle.seekToEndOfFile()
        fileHandle.write(Data(content.utf8))
        fileHandle.closeFile()
      } catch { assertionFailure("An error happened while checking for the file") }
    }
  }
}

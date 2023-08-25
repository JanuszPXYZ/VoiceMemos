//
//  VoiceMemo.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 16/08/2023.
//

import Foundation

// MARK: Removed the NSSecureCoding protocol, the app will fail


final class VoiceMemo: NSObject, Codable {

    var title: String
    var url: URL
    var dateString: Date
    var timeString: Date


    init(title: String, url: URL, dateString: Date, timeString: Date) {
        self.title = title
        self.url = url
        self.dateString = dateString
        self.timeString = timeString
    }

    convenience init(title: String, url: URL) {
        let date = Date()
        self.init(title: title, url: url, dateString: date, timeString: date)
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case url
        case dateString
        case timeString
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(dateString, forKey: .dateString)
        try container.encode(timeString, forKey: .timeString)
    }

    required convenience init(from decoder: Decoder) throws {
        var title: String
        var url: URL
        var dateString: Date
        var timeString: Date
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(URL.self, forKey: .url)
        dateString = try container.decode(Date.self, forKey: .dateString)
        timeString = try container.decode(Date.self, forKey: .timeString)

        self.init(title: title, url: url, dateString: dateString, timeString: timeString)
    }

    func dateStringWithDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"

        return dateFormatter.string(from: date)
    }

    func timeStringWithDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    func retrieveMemos(from filePath: String) -> [VoiceMemo]? {
      guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data else { return nil }
      do {
        let voiceMemos = try PropertyListDecoder().decode([VoiceMemo].self, from: data)
        return voiceMemos
      } catch {
        print("Retrieve Failed")
        return nil
      }
    }

    func formatterWithFormat(template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    func deleteMemo() {
        do {
            try FileManager.default.removeItem(at: self.url)
        } catch {
            print(error.localizedDescription)
        }
    }
}

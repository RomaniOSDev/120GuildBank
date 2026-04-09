import Foundation

func formattedDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy, HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}

func formattedShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}


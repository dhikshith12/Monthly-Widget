//
//  DateWidget.swift
//  DateWidget
//
//  Created by Dhikshith Reddy on 12/02/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
}

struct DateWidgetEntryView : View {
    var entry: Provider.Entry
    var config: MonthConfig

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
            
            VStack{
                HStack(alignment: .center, spacing: 4){
                    Text(config.emojiText)
                        .font(.title)
                        .minimumScaleFactor(0.6)
                    Text(entry.date.weekdayDisaplyFormat)
                        .font(.title)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(config.weekdayTextColor)
                    Spacer()
                }
                Text(entry.date.dayDisplayFormat)
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(config.weekdayTextColor)
            }
            .padding()
        }
    }
}

struct DateWidget: Widget {
    let kind: String = "DateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            var config: MonthConfig = MonthConfig.determineConfig(from: entry.date);
            if #available(iOS 17.0, *) {
                DateWidgetEntryView(entry: entry, config: config)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DateWidgetEntryView(entry: entry, config: config)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Monthly Style")
        .description("New theme of the widget every month.")
        .disableContentMarginsIfNeeded()
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DateWidget()
} timeline: {
    for monthItr in 1...12 {
        DayEntry(date: Date(month: monthItr, day: monthItr, year: 2024))
    }
}

extension Date {
    var weekdayDisaplyFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

extension Date {
    init(month: Int, day: Int, year: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.year = year
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = .current
        dateComponents.calendar = .current
        self = Calendar.current.date(from: dateComponents) ?? Date()
    }
}

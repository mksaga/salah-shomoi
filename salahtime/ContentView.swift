//
//  ContentView.swift
//  salahtime
//
//  Created by Mohamed Aly on 4/1/24.
//

import SwiftUI

// MARK: structs
struct Time {
    var sec: Int
    var min: Int
    var hour: Int
}

struct SalahWindow: Hashable {
    var name: String
    var startTime: Date?
    var endTime: Date?
    var color: Color
}

struct salahWindows: View {
    var hours: Int
    var windows: [SalahWindow]
    var diameter: CGFloat
    var body: some View {
        EmptyView()
        ForEach(windows, id: \.self) { window in
            WindowArc(
                startAngle: timeToAngle(time: window.startTime, hours: hours),
                endAngle: timeToAngle(time: window.endTime, hours: hours),
                diameter: diameter
            ).fill(window.color)
        }
    }
}

struct face: View {
    @Binding var currentTime: Time
    @State var degrees: Double = 0.0
    var hours: Int
    var windows: [SalahWindow]
    var diameter = UIScreen.main.bounds.width - 80
    var body: some View {
        ZStack {
            // MARK: background
            Circle()
                .fill(.ultraThinMaterial)
            // The colored arcs around the edge
            salahWindows(hours: hours, windows: windows, diameter: diameter)
            // MARK: ticks
            ticks(diameter: diameter)
            if hours == 24 || currentTime.hour > 11 {
                hand(
                    degrees: timeToDegrees(time: currentTime, hours: hours),
                    diameter: diameter
                )
            }
            Circle()
                .frame(width: 20)
            
        }
        .frame(width: diameter, height: diameter)
    }
    
    private func timeToDegrees(time: Time, hours: Int) -> Double {
        // 360 * [ (hours + minutes) / hours * 60 ]
        let fraction: Double = Double(time.hour * 60 + time.min) / Double(hours * 60)
        return 360.0 * fraction
    }
}



func timeToAngle(time: Date?, hours: Int) -> Double {
    let components = Calendar.current.dateComponents([.hour, .minute], from: time!)
    // 360 * [ (hours + minutes) / hours * 60 ]
    let fraction: Double = Double(components.hour! * 60 + components.minute!) / Double(hours * 60)
    return 270.0 + (360.0 * fraction)
}

struct WindowArc : Shape {
    var startAngle: Double
    var endAngle: Double
    var diameter: CGFloat
    func path(in rect: CGRect) -> Path {
        let radius = diameter / 2.0
        var p = Path()
        p.addArc(center: CGPoint(x: radius, y:radius), radius: radius, startAngle: .degrees(startAngle - 1), endAngle: .degrees(endAngle - 2), clockwise: false)

        return p.strokedPath(.init(lineWidth: 3))
    }
}

struct ticks: View {
    var diameter: CGFloat
    let hours = 24
    var body: some View {
        // ticks per hour = (360 / (hours * 5))
        ForEach(0..<24 * 5, id: \.self) { mark in
            Rectangle()
                .fill(Color.primary)
                .frame(width:  1, height: (mark % 5) == 0 ? 7 : 2)
                .offset(y: (diameter - 20) / 2)
                .rotationEffect(.init(degrees: Double(mark) * (360 / (24 * 5))))
        }
    }
}

struct hand: View {
    var degrees: Double
    var diameter: CGFloat
    var body: some View {
        Rectangle()
            .fill(Color.primary)
            .frame(width: 5, height: (diameter - 30) / 2)
            .cornerRadius(2)
            .offset(y: -(diameter - 40) / 4)
            .rotationEffect(.init(degrees: degrees))
    }
}

struct clockFace: View {
    @Binding var currentTime: Time
    var width = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                
            ForEach(0..<60) { second in
                Rectangle()
                    .fill(Color.primary)
                    .frame(width:  0.6, height: (second % 5) == 0 ? 7 : 2)
                    .offset(y: (width - 313) / 2)
                    .rotationEffect(.init(degrees: Double(second) * 6))
            }
            
            Rectangle()
                .fill(Color.primary)
                .frame(width: 1, height: (width - 300) / 2)
                .cornerRadius(2)
                .offset(y: -(width - 300) / 4)
                .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
        
            Rectangle()
                .fill(Color.primary)
                .frame(width: 1.8, height: (width - 310) / 2)
                .cornerRadius(2)
                .offset(y: -(width - 310) / 4)
                .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
           
            Rectangle()
                .fill(Color.primary)
                .frame(width: 2.5, height: (width - 340) / 2)
                .cornerRadius(2)
                .offset(y: -(width - 340) / 4)
                .rotationEffect(.init(degrees: Double(currentTime.hour) * 30))
            
            Circle()
                .fill(Color.primary)
                .frame(width: 9, height: 7)
        }
        .frame(width: width - 300, height: width - 300)
        
    }
}

struct Watch: View {
    @State var currentTime = Time(sec: 15, min: 10, hour: 10)
    @State var windows: [SalahWindow] = []
    var receiver = Timer.publish(every: 5 * 60, on: .current, in: .default).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            face(
                currentTime: $currentTime,
                hours: 24,
                windows: windows
            )
            Spacer()
        }
        .onAppear(perform: {
            getTimeComponents()
            getSalahWindows()
        })
        .onReceive(receiver) { _ in
            getTimeComponents()
        }
    }

    private func getSalahWindows() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.windows = [
            SalahWindow(
                name: "fajr",
                startTime: formatter.date(from: "2024-04-01T04:56:00-04:00"),
                endTime: formatter.date(from: "2024-04-01T06:39:00-04:00"),
                color: .green
            ),
            SalahWindow(
                name: "dhuhr",
                startTime: formatter.date(from: "2024-04-01T13:00:00-04:00"),
                endTime: formatter.date(from: "2024-04-01T16:34:00-04:00"),
                color: .blue
            ),
            SalahWindow(
                name: "asr",
                startTime: formatter.date(from: "2024-04-01T16:34:00-04:00"),
                endTime: formatter.date(from: "2024-04-01T19:22:00-04:00"),
                color: .purple
            ),
            SalahWindow(
                name: "maghrib",
                startTime: formatter.date(from: "2024-04-01T19:22:00-04:00"),
                endTime: formatter.date(from: "2024-04-01T20:52:00-04:00"),
                color: .orange
            ),
            SalahWindow(
                name: "isha",
                startTime: formatter.date(from: "2024-04-01T20:52:00-04:00"),
                endTime: formatter.date(from: "2024-04-01T23:59:00-04:00"),
                color: .red
            )
        ]
    }
    
    private func getTimeComponents() {
        let calender = Calendar.current
        let sec = calender.component(.second, from: Date())
        let min = calender.component(.minute, from: Date())
        let hour = calender.component(.hour, from: Date())
        currentTime = Time(sec: sec, min: min, hour: hour)
    }
}

#Preview {
    Watch()
}

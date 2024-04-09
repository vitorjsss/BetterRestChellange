//
//  ContentView.swift
//  BetterRestChellange
//
//  Created by Vitor on 09/04/24.
//

import SwiftUI
import CoreML

struct ContentView: View{
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var idealSleep: String = ""
    
    @State private var wakeUp = defaultWakeTime
    
    var body: some View{
        NavigationStack {
            Form{
                Section(header: Text("When do you want to wake up?")) {
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section(header: Text("Desired amount of  sleep")) {
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section (header: Text("Daily coffee intake")){
                    
                    Picker("Number of cups:", selection: $coffeeAmount){
                        ForEach(1 ..< 21) {
                            Text($0 == 1 ? "1 cup" : "\($0) cups")
                        }
                    }
                    
                }
                
                Section {
                    Text("Your recommended bedtime is: \(idealSleep)")
                        .font(.title2)
                }

                .onChange(of: coffeeAmount) { _ in
                    updateIdealSleep()
                }
                .onChange(of: wakeUp) { _ in updateIdealSleep()
                }
                .onChange(of: sleepAmount) { _ in updateIdealSleep()
                }
                .onAppear {
                    updateIdealSleep()
                }

            }
            .navigationTitle("BetterRest")
            
        }
    }
    
    func calculateBedTime() -> String{
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
                        
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 % 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedtime"
        }
    }
    
    func updateIdealSleep() {
            // Your calculation logic here
            idealSleep = calculateBedTime()
    }
    
}

#Preview {
    ContentView()
}

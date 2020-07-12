//
//  FloraRowView.swift
//  Example
//
//  Created by Jan Scheithauer on 12.07.20.
//  Copyright © 2020 Jan Scheithauer. All rights reserved.
//

import SwiftUI

struct FloraRowView: View {
    var floraViewData: FloraViewData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.floraViewData.sensorName ?? "not defined").font(.title)
            Spacer()
            HStack() {
                VStack {
                    Text("Temperatur").font(.headline)
                    Text(String(format:"%.1f°", self.floraViewData.temp)).font(.body)
                }
                Spacer()
                VStack {
                    Text("Feuchtigkeit").font(.headline)
                    Text("\(self.floraViewData.moisture)").font(.body)
                }
                Spacer()
                VStack {
                    Text("Lux").font(.headline)
                    Text("\(self.floraViewData.lux)").font(.body)
                }
            }
            Spacer()
            HStack() {
                VStack {
                    Text("Leitfähigkeit").font(.headline)
                    Text("\(self.floraViewData.conductivity)").font(.body)
                }
                Spacer()
                VStack {
                    Text("Batterie").font(.headline)
                    Text("\(self.floraViewData.battery)").font(.body)
                }
                Spacer()
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading).padding().background(Color.blue).cornerRadius(16.0)
        
    }
}

struct FloraRowView_Previews: PreviewProvider {
    static var previews: some View {
        FloraRowView(floraViewData: FloraViewData(sensorName: "Test", temp: 0.0, lux: 1, moisture: 1, conductivity: 1, battery: 100))
    }
}

//
//  ContentView.swift
//  Example
//
//  Created by Jan Scheithauer on 10.07.20.
//  Copyright © 2020 Jan Scheithauer. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var floraObserver: FloraObserver = FloraObserver()
    
    var body: some View {
        List() {
            ForEach(floraObserver.floraViewDataset) { floraViewData in
                FloraRowView(floraViewData: floraViewData).tag(floraViewData)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

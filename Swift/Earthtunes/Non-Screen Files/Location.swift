//
//  Location.swift
//  Earthtunes
//
//  Created by Cooper Barth on 6/22/19.
//  Copyright © 2019 Cooper Barth. All rights reserved.
//

struct Location {
    var name: String
    var network: String
    var station: String

    init(name: String, network: String, station: String) {
        self.name = name
        self.network = network
        self.station = station
    }
}

//
//  This file is part of the NineAnimator project.
//
//  Copyright © 2018-2020 Marcus Zhou. All rights reserved.
//
//  NineAnimator is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NineAnimator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with NineAnimator.  If not, see <http://www.gnu.org/licenses/>.
//

import Alamofire
import Foundation

extension NASourceArrayanime {
    fileprivate struct AnimeResponse: Codable {
        let results: [AnimeEntry]
    }
    
    fileprivate struct AnimeEntry: Codable {
        let title: String
        let id: String
        let image: String
        let episodenumber: String?
    }
    
    func featured() -> NineAnimatorPromise<FeaturedContainer> {
        NineAnimatorPromise<[AnimeLink]>.queue(listOfPromises: [
            popularAnimeUpdates, latestAnimeUpdates
        ]) .then { results in BasicFeaturedContainer(featured: results[0], latest: results[1]) }
    }
    
    fileprivate var popularAnimeUpdates: NineAnimatorPromise<[AnimeLink]> {
        self.requestManager.request(
            url: self.vercelEndpoint.absoluteString + "/newseason/1",
            handling: .default
        ) .responseDecodable(
            type: AnimeResponse.self
        ) .then {
            animeResponse in
            let seasonalAnime = try animeResponse.results
                .map {
                animeEntry -> AnimeLink in
                
                let animeURL = try URL(string: self.endpoint + "/ani/\(animeEntry.id)").tryUnwrap(.urlError)
                
                return AnimeLink(
                    title: animeEntry.title,
                    link: animeURL,
                    image: try URL(string: animeEntry.image).tryUnwrap(.urlError),
                    source: self
                )
            }
            return seasonalAnime
        }
    }
    
    fileprivate var latestAnimeUpdates: NineAnimatorPromise<[AnimeLink]> {
        self.requestManager.request(
            url: self.vercelEndpoint.absoluteString + "/recentlyadded/1",
            handling: .default
        ) .responseDecodable(
            type: AnimeResponse.self
        ) .then {
            animeResponse in
            let recentAnime = try animeResponse.results
                .map {
                animeEntry -> AnimeLink in
                
                let animeURL = try URL(string: self.endpoint + "/ani/\(animeEntry.id)").tryUnwrap(.urlError)
                
                return AnimeLink(
                    title: animeEntry.title,
                    link: animeURL,
                    image: try URL(string: animeEntry.image).tryUnwrap(.urlError),
                    source: self
                )
            }
            return recentAnime
        }
    }
}

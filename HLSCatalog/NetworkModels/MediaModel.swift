//
//  MediaModel.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/18/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import AVFoundation

struct MediaModel: Codable {
    
    var title: String?
    var playlist: [MediaPlaylistData]?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case playlist = "encodings"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(playlist, forKey: .playlist)
    }
    
    init(from decoder: Decoder) throws {
        do{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String?.self, forKey: .title)
        playlist = try container.decode([MediaPlaylistData]?.self, forKey: .playlist)
    } catch {
    print(error)
    }
    }
    
    func convertToStream() -> Stream? {
        guard let title = self.title,
            let playlistUrl = self.playlist?.first?.playlistUrl else {
                return nil
        }
        let stream = Stream(name: title, playlistURL: playlistUrl)
        return stream
    }
}

struct MediaPlaylistData: Codable {
    var playlistUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case playlistUrl = "master_playlist_url"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playlistUrl, forKey: .playlistUrl)
    }
    
    init(from decoder: Decoder) throws {
        do {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playlistUrl = try container.decode(String?.self, forKey: .playlistUrl)
        } catch {
            print(error)
        }
    }
}

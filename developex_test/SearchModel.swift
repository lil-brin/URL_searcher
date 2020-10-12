//
//  SearchModel.swift
//  developex_test
//
//  Created by Brin on 6/18/19.
//  Copyright © 2019 Brin. All rights reserved.
//

import Foundation

protocol SearchServiceDelegate: NSObjectProtocol {
    func didUpdateLinksDictionary()
    func didFinishSearch()
}

class SearchService {
    
    weak var delegate: SearchServiceDelegate?
    var urls: [String] = [String]()
    var urlStatuses: [String: String] = [String: String]()
    private var stop: Bool = false
    private var threadsNumber: Int = 0
    private var searchingDepth: Int = 0
    private var currentUrl: Int = 0
    private var searchingText: String = ""
    private lazy var session: URLSession = { return URLSession(configuration: .default) }();
    private let timeoutInterval: TimeInterval = 10
    
    func startSearch(startUrl: String, threadsNumber: Int, searchingText: String, searchingDepth: Int) {
        
        self.searchingDepth = searchingDepth
        self.searchingText = searchingText.lowercased()
        self.threadsNumber = threadsNumber
        currentUrl = 0
        urls.removeAll()
        urlStatuses.removeAll()
        search(in: startUrl)
        
    }
    
    func stopSearch() {
        searchingDepth = 0
        delegate?.didFinishSearch()
    }
    
    private func search(in url: String) {
        
        if currentUrl > searchingDepth {
            return
        }
        if urlStatuses[url] == nil && urls.count < searchingDepth && !url.isEmpty {
            urls.append(url)
            urlStatuses[url] = "searching"
            delegate?.didUpdateLinksDictionary()
        }
        
        while urls.count >= currentUrl + 1 && threadsNumber > 0 {
            let urlString = urls[currentUrl]
            guard let url = URL(string: urlString) else {
                currentUrl.increase()
                continue
            }
            threadsNumber.decrease()
            currentUrl.increase()
            performRequest(with: url)
        }
    }
    
    func parseLinks(text: String) {
        DispatchQueue.global().async {
            let newLinks = text.extractURLs()
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                if newLinks.isEmpty {
                    self.search(in: "")
                }
                newLinks.forEach { self.search(in: $0.absoluteString) }
            }
        }
    }
    
    private func performRequest(with url: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            let localUrlString = url.absoluteString
            var urlRequest = URLRequest(url: url)
            urlRequest.timeoutInterval = self.timeoutInterval
            let task = self.session.dataTask(with: urlRequest) {
                (data, response, error) in
                
                if let data = data,
                    let dataText = String(data: data, encoding: .utf8)?.lowercased() {
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        if error != nil {
                            self.urlStatuses[localUrlString] = error.debugDescription
                        } else if dataText.contains(self.searchingText) {
                            self.urlStatuses[localUrlString] = "found"
                        } else {
                            self.urlStatuses[localUrlString] = "not found"
                        }
                        print(data)
                        self.delegate?.didUpdateLinksDictionary()
                        self.threadsNumber.increase()
                        self.parseLinks(text: dataText)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.urlStatuses[localUrlString] = "noData"
                        self.delegate?.didUpdateLinksDictionary()
                        self.threadsNumber.increase()
                        self.search(in: "")
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    if self.currentUrl == self.searchingDepth {
                        self.delegate?.didFinishSearch()
                    }
                }
            }
            task.resume()
        }
    }
}

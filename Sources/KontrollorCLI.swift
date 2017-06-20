//
//  KontrollorCLI.swift
//  Kontrollor
//
//  Created by Victor Sigler Lopez on 6/19/17.
//
//

import Foundation
import Files
import Rainbow

/// This class define a entry point to the CLI tool
public final class KontrollorCLI {
    
    // MARK: - Properties
    
    /// The args to provide
    private let arguments: [String]
    
    // MARK: - Initializer
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    // MARK: - Methods
    
    public func run() throws {
        
        let (mainFolder, testFolder) = try parseArguments(arguments)
        
        // check if the folder is empty
        guard testFolder.files.count > 0 else {
            throw Error.emptyDirectoryTests
        }
        
        let mainFiles = Set(mainFolder.makeFileSequence(recursive: true, includeHidden: false)
            .filter { $0.extension == "swift" && $0.nameExcludingExtension != "AppDelegate" }
            .sorted(by: { $0.0.modificationDate.compare($0.1.modificationDate) == .orderedAscending })
            .map { $0.name })
        
        
        let unitTestFiles = Set(testFolder.makeFileSequence(recursive: true, includeHidden: false)
            .filter { $0.extension == "swift" }
            .map { $0.name.replacingOccurrences(of: "Spec", with: "") // QuickSpec
                .replacingOccurrences(of: "Test", with: "") // XCTest
        })
        
        let fileWithoutTests = mainFiles.subtracting(unitTestFiles).sorted(by: {  $0 < $1})
        
        if !fileWithoutTests.isEmpty {
            print("⚠️  We found \(fileWithoutTests.count) files that doesn't have a matching unit test file.".lightWhite.bold)
            for fileName in fileWithoutTests {
                print("   ✔ ".lightRed + fileName)
            }
        }
    }
    
    private func existFolder(named: String) throws -> Folder {
        guard let folder = (Folder.current.makeSubfolderSequence(recursive: true)
            .filter { $0.name == named }.first) else {
                throw Error.missingDirectoryTests
        }
        
        return folder
    }
    
    private func parseArguments(_ arguments: [String]) throws -> (Folder, Folder) {
        
        guard arguments.count > 1 else {
            throw Error.missingDirectoryNameTests
        }
        
        guard let mainFolderNameIndex = arguments.index(of: "--mainFolder") else {
            throw Error.missingMainDirectoryName
        }
        
        guard let testFolderIndex = arguments.index(of: "--testFolder") else {
            throw Error.missingDirectoryNameTests
        }
        
        let mainFolderName = arguments[mainFolderNameIndex.advanced(by: 1)].replacingOccurrences(of: "--", with: "")
        let testFolderName = arguments[testFolderIndex.advanced(by: 1)].replacingOccurrences(of: "--", with: "")
        
        // find the unit test bundle directory
        guard let mainFolder = try? existFolder(named: mainFolderName) else {
            throw Error.missingMainDirectory
        }
        
        // find the unit test bundle directory
        guard let unitTestFolder = try? existFolder(named: testFolderName) else {
            throw Error.missingDirectoryTests
        }
        
        return (mainFolder, unitTestFolder)
    }
}

public extension KontrollorCLI {
    
    // MARK: - Errors
    
    enum Error: Swift.Error, LocalizedError {
        case missingDirectoryNameTests
        
        case missingMainDirectoryName
        case missingMainDirectory
        
        case missingDirectoryTests
        case emptyDirectoryTests
        
        public var errorDescription: String? {
            switch self {
            case .missingDirectoryNameTests:
                return NSLocalizedString("Missing directory name for unit tests.", comment: "")
            case .missingMainDirectoryName:
                return NSLocalizedString("Missing directory name for the main folder.", comment: "")
            case .missingDirectoryTests:
                return NSLocalizedString("The directoy for the unit tests couldn't be found.", comment: "")
            case .missingMainDirectory:
                return NSLocalizedString("The directoy for the main folder couldn't be found.", comment: "")
            case .emptyDirectoryTests:
                return NSLocalizedString("Your unit tests directory is completely empty.", comment: "")
            }
        }
    }
}

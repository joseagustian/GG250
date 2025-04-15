//
//  FavoriteGameProvider.swift
//  GG250
//
//  Created by Jose Agustian on 10/04/25.
//

import CoreData
import UIKit
 
class FavoriteGameProvider {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteGame")
        
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil
        
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
            let taskContext = persistentContainer.newBackgroundContext()
            taskContext.undoManager = nil
            
            taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return taskContext
    }
    
    func getAllFavorite(completion: @escaping(_ favorites: [FavoriteGameModel]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [FavoriteGameModel] = []
                for result in results {
                    let game = FavoriteGameModel(
                        id: result.value(forKeyPath: "gameId") as? Int32,
                        title: result.value(forKeyPath: "title") as? String,
                        rating: result.value(forKeyPath: "rating") as? Double,
                        releaseDate: result.value(forKeyPath: "releaseDate") as? String,
                        gamePosterPath: result.value(forKeyPath: "gamePosterPath") as? URL,
                        gameMetascore: result.value(forKeyPath: "gameMetaScore") as? Int32,
                        gameRatingDescription: result.value(forKeyPath: "gameRatingDesc") as? String,
                        gameDescription: result.value(forKeyPath: "gameDesc") as? String,
                        favorite: result.value(forKeyPath: "isFavorite") as? Bool
                    )
                    games.append(game)
                }
                completion(games)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func getFavoritedGame(_ id: Int, completion: @escaping(_ games: FavoriteGameModel) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Game")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(id)")
            do {
                if let result = try taskContext.fetch(fetchRequest).first  {
                    let game = FavoriteGameModel(
                        id: result.value(forKeyPath: "gameId") as? Int32,
                        title: result.value(forKeyPath: "title") as? String,
                        rating: result.value(forKeyPath: "rating") as? Double,
                        releaseDate: result.value(forKeyPath: "releaseDate") as? String,
                        gamePosterPath: result.value(forKeyPath: "gamePosterPath") as? URL,
                        gameMetascore: result.value(forKeyPath: "gameMetaScore") as? Int32,
                        gameRatingDescription: result.value(forKeyPath: "gameRatingDesc") as? String,
                        gameDescription: result.value(forKeyPath: "gameDesc") as? String,
                        favorite: result.value(forKeyPath: "isFavorite") as? Bool
                    )
     
                    completion(game)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func setFavoriteGame(
        _ id: Int32,
        _ title: String,
        _ rating: Double?,
        _ releaseDate: String?,
        _ gamePosterPath: URL?,
        _ gameMetascore: Int32?,
        _ gameRatingDescription: String?,
        _ gameDescription: String?,
        _ favorite: Bool,
        completion: @escaping() -> Void
    ) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: "Game", in: taskContext) {
                let game = NSManagedObject(entity: entity, insertInto: taskContext)
                game.setValue(id, forKeyPath: "gameId")
                game.setValue(title, forKeyPath: "title")
                game.setValue(rating, forKeyPath: "rating")
                game.setValue(releaseDate, forKeyPath: "releaseDate")
                game.setValue(gamePosterPath, forKeyPath: "gamePosterPath")
                game.setValue(gameMetascore, forKeyPath: "gameMetaScore")
                game.setValue(gameRatingDescription, forKeyPath: "gameRatingDesc")
                game.setValue(gameDescription, forKeyPath: "gameDesc")
                game.setValue(favorite, forKeyPath: "isFavorite")
                        
                do {
                    try taskContext.save()
                    completion()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func removeFavoriteGame(
        _ id: Int32,
        completion: @escaping() -> Void
    ) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                if batchDeleteResult.result != nil {
                    completion()
                }
            }
        }
    }
}

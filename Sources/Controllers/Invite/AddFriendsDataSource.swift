//
//  AddFriendsDataSource.swift
//  Ello
//
//  Created by Sean on 2/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

struct AddFriendsCellItem {
    let cellType: CellType
    let user: User?
    let person: LocalPerson?

    init(user: User) {
        cellType = .Find
        self.user = user
    }

    init(person: LocalPerson) {
        cellType = .Invite
        self.person = person
    }

    init(person: LocalPerson, user: User?) {
        if let user = user {
            cellType = .FindContact
            self.person = person
            self.user = user
        } else {
            self = AddFriendsCellItem(person: person)
        }
    }

    enum CellType {
        case Find
        case Invite
        case FindContact

        var identifier: String {
            switch self {
            case Find: return "FindFriendsCell"
            case Invite: return "InviteFriendsCell"
            case FindContact: return "FindFriendsCell"
            }
        }
    }
}

class AddFriendsDataSource: NSObject, UITableViewDataSource {

    var items = [AddFriendsCellItem]()
    var relationshipDelegate: RelationshipDelegate?
    var inviteCache = InviteCache()

    // MARK: Public

    func itemAtIndexPath(indexPath: NSIndexPath) -> AddFriendsCellItem? {
        if indexPath.row < countElements(items) {
            return items[indexPath.row]
        }
        return nil
    }

    // MARK: Private

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countElements(items)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let item: AddFriendsCellItem = itemAtIndexPath(indexPath) {
            var cell = tableView.dequeueReusableCellWithIdentifier(item.cellType.identifier, forIndexPath: indexPath) as UITableViewCell
            AddFriendsCellPresenter.configure(cell, addFriendsCellItem: item, relationshipDelegate: relationshipDelegate, inviteCache: inviteCache)

            if let cell = cell as? InviteFriendsCell {
                item.person.map { person in
                    cell.delegate = InviteController(person: person) {
                        self.inviteCache.saveInvite(person.identifier)
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
}
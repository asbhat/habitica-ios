//
//  FixCharacterViewController.swift
//  Habitica
//
//  Created by Phillip on 25.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class FixCharacterViewController: HRPGBaseViewController {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
    let userRepository = UserRepository()
    
    var stats: [String: Float] = [
        "stats.hp": 0.0,
        "stats.exp": 0.0,
        "stats.mp": 0.0,
        "stats.gp": 0.0,
        "stats.lvl": 0
    ]
    
    var habitClass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView()
        
        let label = UILabel()
        label.text = NSLocalizedString("If you’ve encountered a bug or made a mistake that unfairly changed your character, you can manually correct those values here.", comment: "")
        view.backgroundColor = UIColor.gray700()
        label.textColor = UIColor.gray300()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = self.view.frame.size.width-52
        label.frame = CGRect(origin: CGPoint(x: 26, y: 10), size: label.intrinsicContentSize)
        view.frame = CGRect(x: 0, y: 0, width: label.frame.size.width+42, height: label.frame.size.height+20)
        view.addSubview(label)
        tableView.tableHeaderView = view
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.stats["stats.hp"] = user.stats?.health
            self?.stats["stats.exp"] = user.stats?.experience
            self?.stats["stats.mp"] = user.stats?.mana
            self?.stats["stats.gp"] = user.stats?.gold
            self?.stats["stats.lvl"] = Float(user.stats?.level ?? 0)
            //self.stats["achievements.streak"] = user?.health
            self?.habitClass = user.stats?.habitClass ?? ""
            self?.tableView.reloadData()
        }).start())
    }
    
    private func identifierFor(index: Int) -> String {
        switch index {
        case 0:
            return "stats.hp"
        case 1:
            return "stats.exp"
        case 2:
            return "stats.mp"
        case 3:
            return "stats.gp"
        case 4:
            return "stats.lvl"
        case 5:
            return "achievements.streak"
        default:
            return ""
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let titleLabel = cell.viewWithTag(1) as? UILabel,
            let iconView = cell.viewWithTag(3) as? UIImageView,
            let valueField = cell.viewWithTag(2) as? UITextField {
            configure(item: indexPath.item, titleLabel: titleLabel, iconView: iconView, valueField: valueField)
        }
        if let wrapper = cell.viewWithTag(4) {
            wrapper.layer.borderColor = UIColor.gray600().cgColor
            wrapper.layer.borderWidth = 1
        }
        
        return cell
    }
    
    private func configure(item: Int, titleLabel: UILabel, iconView: UIImageView, valueField: UITextField) {
        valueField.text = "\(stats[identifierFor(index: item)] ?? 0)"
        switch item {
        case 0:
            titleLabel.text = NSLocalizedString("Health", comment: "")
            titleLabel.textColor = .red10()
            iconView.backgroundColor = UIColor.red500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfHeartLightBg
            return
        case 1:
            titleLabel.text = NSLocalizedString("Experience", comment: "")
            titleLabel.textColor = .yellow10()
            iconView.backgroundColor = UIColor.yellow500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfExperience
            return
        case 2:
            titleLabel.text = NSLocalizedString("Mana Points", comment: "")
            titleLabel.textColor = .blue10()
            iconView.backgroundColor = UIColor.blue500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfMagic
            return
        case 3:
            titleLabel.text = NSLocalizedString("Gold", comment: "")
            titleLabel.textColor = .yellow10()
            iconView.backgroundColor = UIColor.yellow500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfGold
            return
        case 4:
            titleLabel.text = NSLocalizedString("Character Level", comment: "")
            titleLabel.textColor = .purple300()
            configure(iconView: iconView, forHabitClass: habitClass)
            return
        case 5:
            titleLabel.text = NSLocalizedString("21-Day Streaks", comment: "")
            titleLabel.textColor = .gray10()
            iconView.backgroundColor = UIColor.gray500().withAlphaComponent(0.5)
            iconView.image = #imageLiteral(resourceName: "streak_achievement")
            return
        default:
            return
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        userRepository.updateUser(stats).observeCompleted {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if let cell = sender.superview?.superview?.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            stats[identifierFor(index: indexPath.item)] = Float(sender.text ?? "")
        }
    }
    
    func configure(iconView: UIImageView, forHabitClass habitClass: String) {
        switch habitClass {
        case "warrior":
            iconView.backgroundColor = UIColor.red500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfWarriorLightBg
            return
        case "wizard":
            iconView.backgroundColor = UIColor.blue500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfMageLightBg
            return
        case "healer":
            iconView.backgroundColor = UIColor.yellow500().withAlphaComponent(0.5)
            iconView.image = HabiticaIcons.imageOfHealerLightBg
            return
        case "rogue":
            iconView.backgroundColor = UIColor.purple400().withAlphaComponent(0.2)
            iconView.image = HabiticaIcons.imageOfRogueLightBg
            return
        default:
            return
        }
    }
}

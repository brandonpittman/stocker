stocker
======

## Usage

    stocker buy ITEM          # Open link to buy ITEM
    stocker check             # Check for low stock items.
    stocker count             # Take an interactive inventory.
    stocker csv               # Write entire inventory as CSV.
    stocker delete ITEM       # Delete ITEM from inventory.
    stocker help [COMMAND]    # Describe available commands or one specific command
    stocker list              # List all inventory items and total on hand.
    stocker min ITEM MINIMUM  # Set minimum acceptable amount for ITEM.
    stocker new ITEM TOTAL    # Add ITEM with TOTAL on hand to inventory.
    stocker total ITEM TOTAL  # Set TOTAL of ITEM.
    stocker url ITEM URL      # Set URL of ITEM.

## Adding new items to the database

When you use `stocker new ITEM TOTAL`, there are default values set for MINIMUM and URL. These are 1 and http://amazon.com, respectively. You can easily change these with `--minimum` and `--url` when creating new items. In addition to this, you can set a global default url by using `stocker config --url SOME_URL`. You can also use `stocker min` and `stocker url` after creation as well if necessary.

## Getting a list of all items

`stocker list` will pretty print a list of all items, with well-stocked items in green, items close to running out in yellow and low-count items in red. If you need a data dump to parse with awk, use `stocker csv`.

## Taking inventory

`stocker count` will run through you every item in your inventory and let you interactively enter current totals for each one. You can alternatively use `stocker total ITEM TOTAL` to enter a new total for a single item.

## Tips

When you're using `delete`, `total`, `min` and `total` you can just use a part of the item's name. stocker will attempt to match the name of the item using a regex.

Example: `stocker total toilet 12` will match 'toilet paper' and set it's total to 12.

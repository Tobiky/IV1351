from db import DB
import pprint

pp = pprint.PrettyPrinter(indent=4)
with DB() as db:
    usr_input = ''
    while True:
        print('\n# ', end='')
        usr_input = input().lower()
        print('-' * 80)
        if 'exit' in usr_input:
            break

        if 'help' in usr_input:
            print('help')
            print('exit')
            print('list <instrument name>')
            print('rent <product id> <student id>')
            print('terminate <product id> <student id>')
            continue
        
        cmd = usr_input.split(' ')

        if cmd[0] == 'list':
            result = db.list(cmd[1])
            print('product id'.ljust(15), end='')
            print('brand'.ljust(15), end='')
            print('stock'.ljust(15), end='')
            print('rental charge'.ljust(15))

            for product_id, brand, stock, rental_charge, _ in result:
                print(str(product_id).ljust(15), end='')
                print(str(brand).ljust(15), end='')
                print(str(stock).ljust(15), end='')
                print(str(rental_charge).ljust(15))
            continue

        if cmd[0] == 'rent':
            pp.pprint(db.rent(int(cmd[1]), int(cmd[2])))
            continue

        if cmd[0] == 'terminate':
            pp.pprint(db.terminate(int(cmd[1]), int(cmd[2])))

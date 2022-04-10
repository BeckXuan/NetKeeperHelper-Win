import time
import hashlib
from win32 import win32ras
import sys
import getopt
import json
import datetime

# 闪讯账号
default_username = '12345678900@XXXX.XY'
# PPPoE拨号连接的名称
default_entry = 'Netkeeper'
json_path = sys.path[0] + '/Netkeeper.json'


def get_PIN(username):
    RADIUS = 'singlenet01'
    PREFIX0 = '\r'
    PREFIX1 = '\n'

    timenow = int(time.time())
    timedivbyfive = timenow // 5
    timeByte = [timedivbyfive >> (8 * (3 - i)) & 0xFF for i in range(4)]
    beforeMD5 = timeByte
    beforeMD5 += list(map(ord, username[:username.index('@')]))
    beforeMD5 += list(map(ord, RADIUS))
    m = hashlib.md5()
    m.update(bytes(beforeMD5[:len(RADIUS)+16]))
    afterMD5 = m.hexdigest()
    MD501 = afterMD5[0:2]

    temp = []
    for i in range(32):
        t = (31 - i) // 8
        temp.append(timeByte[t] & 1)
        timeByte[t] >>= 1

    timeHash = []
    for i in range(4):
        timeHash.append(temp[i] * 128 + temp[4 + i] * 64 + temp[8 + i]
                        * 32 + temp[12 + i] * 16 + temp[16 + i] * 8 + temp[20 + i]
                        * 4 + temp[24 + i] * 2 + temp[28 + i])

    temp[1] = (timeHash[0] & 3) << 4
    temp[0] = (timeHash[0] >> 2) & 0x3F
    temp[2] = (timeHash[1] & 0xF) << 2
    temp[1] = (timeHash[1] >> 4 & 0xF) + temp[1]
    temp[3] = timeHash[2] & 0x3F
    temp[2] = ((timeHash[2] >> 6) & 0x3) + temp[2]
    temp[5] = (timeHash[3] & 3) << 4
    temp[4] = (timeHash[3] >> 2) & 0x3F

    PIN27 = []
    for i in range(6):
        PIN27.append(temp[i] + 0x20)
        if PIN27[i] >= 0x40:
            PIN27[i] += 1

    PIN = PREFIX0 + PREFIX1 + ''.join(map(chr, PIN27)) + MD501 + username
    # print(PIN)
    return PIN


def Save_JSON(config):
    with open(json_path, 'w') as f:
        json.dump(config, f, indent=4)


def main(argv):
    entry = default_entry
    username = default_username
    password = ''
    flag = False
    try:
        with open(json_path, 'r') as f:
            config = json.load(f)
    except:
        config = {}

    opts, args = getopt.getopt(argv, "n:u:p:")
    for opt, arg in opts:
        if opt == '-n':
            entry = arg
        elif opt == '-u':
            username = arg
        elif opt == '-p':
            password = arg

    if not password:
        if config.get('valid', False):
            #time = datetime.datetime.strptime(config.get('time', "2000-01-01 00:00:00"), '%Y-%m-%d %H:%M:%S')
            #expiretime = time + datetime.timedelta(days=1, hours=4)
            expiration = datetime.datetime.strptime(config.get('expiration', "2000-01-01 00:00:00"), '%Y-%m-%d %H:%M:%S')
            if expiration > datetime.datetime.now():
                password = config.get('password')
                flag = True
        if not flag:
            password = input('Password: ')

    print('Connecting...')
    dial_params = (entry, '', '', get_PIN(username), password, '')
    handle, code = win32ras.Dial(None, None, dial_params, None)
    if code == 0:
        print('Connection success.')
        if not flag:
            # config['time'] = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            config['expiration'] = (datetime.datetime.now() + datetime.timedelta(days=1, hours=4)).strftime('%Y-%m-%d %H:%M:%S')
            config['valid'] = True
            config['password'] = password
            Save_JSON(config)
    else:
        print(f'Connection failed!\ncode: {code}')
        if code == 691:
            if flag:
                config['valid'] = False
                Save_JSON(config)


if __name__ == "__main__":
    main(sys.argv[1:])

#!/usr/bin/python
# See http://priceonomics.com/jobs/puzzle/
import json, sys, urllib2
exchanges = {}
# multiplier, path to it; TODO: make dict/object?
best_path = (0.0, None)

def find_paths(start, current_multiplier, visited_currencies):
    """Find all the paths through the exchanges, visiting
    each currency only once."""
    # TODO: Consider alternate solutions at 
    # http://en.wikipedia.org/wiki/Shortest_path
    global exchanges, best_path
    if visited_currencies:
        current_currency = visited_currencies[-1]
    else:
        current_currency = start
    unvisited_currencies = (
        set(exchanges.keys()) - set(visited_currencies) - set([start])
        )
    exchange_multiplier = (
        current_multiplier * exchanges[current_currency][start]
        )

    # TODO: skip the start currency?  What if it's not 1.0?
    if exchange_multiplier > best_path[0]:
        best_path = (exchange_multiplier, [start] + visited_currencies)
        print "Found a deal:", best_path
    else:
        print "No better than usual:", (
            exchange_multiplier, [start] + visited_currencies
            )

    for next_currency in unvisited_currencies:
        #next_currency = unvisited_currencies.pop()
        next_multiplier = (
            current_multiplier * exchanges[current_currency][next_currency]
        )
        find_paths(start, next_multiplier, 
            visited_currencies + [next_currency])
    else:
        return


def load_data():
    rates_url = "http://fx.priceonomics.com/v1/rates/"
    exchanges = {}
    # TODO: error handling, set User-Agent header
    json_data = urllib2.urlopen(rates_url).readline()
    data = json.loads(json_data)
    for key in data:
        (start, end) = key.split('_')
        rate = float(data[key])
        print start, "->", end, rate
        if start not in exchanges:
            exchanges[start] = {end: rate}
        elif end not in exchanges[start]:
            exchanges[start][end] = rate
        else:
            sys.exit("Bad data in response:" + repr(data))

    # confirm we have exchanges in both directions
    for start in exchanges:
        for end in exchanges[start]:
            if start not in exchanges[end]:
                sys.exit("No reverse exchange for %s and %s" % (start, end))

    return exchanges

def main():
    global exchanges
    start_currency = u'USD'
    exchanges = load_data()
    print repr(exchanges)
    find_paths(start_currency, 1, [])
    print "Best path found: %f%% increase, %s -> %s" % ((best_path[0]-1)*100, " -> ".join(best_path[1]), start_currency)

if __name__ == "__main__":
    main()

# TODO: implement tests using these examples (and make sure their
# tuples are correct.
#json_data = '{"USD_JPY": "107.3549996", "USD_USD": "1.0000000", "JPY_EUR": "0.0072240", "BTC_USD": "136.2451437", "JPY_BTC": "0.0000772", "USD_EUR": "0.8150719", "EUR_USD": "1.1160498", "EUR_JPY": "114.3482771", "JPY_USD": "0.0092865", "BTC_BTC": "1.0000000", "EUR_BTC": "0.0097712", "BTC_JPY": "13946.8996135", "JPY_JPY": "1.0000000", "BTC_EUR": "100.4978772", "EUR_EUR": "1.0000000", "USD_BTC": "0.0086986"}' # (1.18514200698882, ['USD', u'BTC'])?
#json_data = '{"USD_JPY": "88.2653170", "USD_USD": "1.0000000", "JPY_EUR": "0.0086386", "BTC_USD": "123.1319044", "JPY_BTC": "0.0000923", "USD_EUR": "0.6701372", "EUR_USD": "1.2559969", "EUR_JPY": "128.6869762", "JPY_USD": "0.0111049", "BTC_BTC": "1.0000000", "EUR_BTC": "0.0109965", "BTC_JPY": "12604.5469404", "JPY_JPY": "1.0000000", "BTC_EUR": "90.8252190", "EUR_EUR": "1.0000000", "USD_BTC": "0.0071518"}' # (1.0324250307692449, ['USD', u'JPY', u'EUR', u'BTC'])?

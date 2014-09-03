require 'httparty'
require 'active_support'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/date/acts_like.rb'
require 'active_support/core_ext/date/calculations.rb'
require 'active_support/core_ext/date/conversions.rb'
require 'active_support/core_ext/date/zones.rb'

SPREE_API_URL = 'YOUR URL'
SPREE_API_KEY = 'YOUR KEY'


#gets all orders from past 5 days and groups them by day. Displays total order count and total amount of orders
SCHEDULER.every '5m', :first_in => 0 do |job|

  response = HTTParty.get(SPREE_API_URL + "/orders.json", { body: { per_page: 10000, q: { created_at_gt: 5.days.ago } } ,
                                                            headers: { 'X-Spree-Token' => SPREE_API_KEY }})

  h = {}

  response['orders'].each do |order|
    day = Time.parse(order['created_at']).strftime("%A")

    if h[day]
      h[day]["count"] += 1
      h[day]["cost"] += order['total'].to_f
    else
      h[day] = {"count" => 1 }
      h[day]["cost"] = order['total'].to_f
    end
  end

  points = []
  value_points = []

  (0..4).each do |d|

    day = d.days.ago.strftime("%A")

    if h.has_key? day
      count = h[day]["count"]
      value = h[day]["cost"]
    else
      count = 0
      value = 0.00
    end

    points << { x: (d + 1), y: count }
    value_points << { x: (d + 1), y: value }

    send_event(day, { current: count })
    send_event("#{day}-value", { current: value.to_i })
  end

  send_event(:weekly_graph, points: points, graphtype: 'bar')
  send_event(:weekly_graph_value, points: value_points, graphtype: 'bar')
end

#gets all orders starting from beginning of day and groups them by state
SCHEDULER.every '5m', :first_in => 0 do |job|
  response = HTTParty.get(SPREE_API_URL + "/orders.json", { body: { per_page: 10000, q: { created_at_gt: Time.now.beginning_of_day } } ,
                                                            headers: { 'X-Spree-Token' => SPREE_API_KEY }})

  orders = response['orders']
  total_count = response['count']

  order_hash = {}
  points = []

  orders.each do |order|
    state = get_state(order)

    if order_hash[state]
      order_hash[state]["count"] += 1
    else
      order_hash[state] = { "count" => 1 }
    end

  end

  %w(checkout complete shipped canceled).each_with_index do |state, index|
    if order_hash[state]
      count = order_hash[state]["count"]
    else
      count = 0
    end

    points << { x: (index + 1), y: count }

    send_event("#{state}-totals", { current: count })
  end

  send_event('state-totals', { current: total_count })
  send_event(:order_state_graph, points: points, graphtype: 'bar')
end

def get_state(order)
  order_state = order["state"]
  shipment_state = order["shipment_state"]

  if shipment_state == 'shipped'
    shipment_state
  elsif (order_state == 'address') || (order_state == 'cart') || (order_state == 'payment')
    'checkout'
  else
    order_state
  end
end
// Create new order
let new_order = { "_id" : ObjectId("000000000000000000000002"), "order_date" : ISODate("2021-11-22T00:00:00Z"), "purchaser_id" : NumberLong("1004"), "quantity" : 1, "product_id" : NumberLong("107") }
let message = { aggregateid : new_order._id, aggregatetype : "Order", type : "OrderCreated", payload : new_order }

// Get new sessions
let s = db.getMongo().startSession()

// Save order and message in transaction
s.startTransaction()
s.getDatabase("inventory").orders.insertOne(new_order)
s.getDatabase("inventory").outbox.insertOne(message)
s.commitTransaction()
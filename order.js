// Get new sessions
let s = db.getMongo().startSession()

// STEP 1
// Create new order and send message
let new_order = { "_id" : ObjectId("000000000000000000000002"), "order_date" : ISODate("2021-11-22T00:00:00Z"), "purchaser_id" : NumberLong("1004"), "quantity" : 1, "product_id" : NumberLong("107") }
let new_message = { aggregateid : new_order._id, aggregatetype : "Order", type : "OrderCreated", payload : new_order }

s.startTransaction()
s.getDatabase("inventory").orders.insertOne(new_order)
s.getDatabase("inventory").outbox.insertOne(new_message)
s.commitTransaction()


// STEP 2
// Cancel the order and send message
let cancel_message = { aggregateid : new_order._id, aggregatetype : "Order", type : "OrderCanceled", payload: {} }

s.startTransaction()
s.getDatabase("inventory").orders.deleteOne(new_order)
s.getDatabase("inventory").outbox.insertOne(cancel_message)
s.commitTransaction()
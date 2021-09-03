import 'item.dart';

class Order {
  final int id;
  final DateTime dateTime;
  final List<Item> items;

  Order(this.id, this.dateTime, this.items);

  static List<Order> fetchAll() {
    return [
      Order(1,DateTime.now(),[
        Item(1, 'Coca Cola', 2, 1.50),
        Item(5, 'Gruyère', 1, 4.70),
        Item(33, 'Brot 1kg', 1, 1.80),
        Item(62, 'Wine 1L', 3, 15.00)
      ]),
      Order(2,DateTime.now(),[
        Item(2, 'Pepsi', 2, 1.50),
        Item(7, 'Emmental', 1, 4.70),
        Item(30, 'Pane', 1, 1.80),
        Item(35, 'X', 1, 1.80),
        Item(39, 'Y', 1, 1.80),
        Item(30, 'Pane', 1, 1.80),
        Item(35, 'X', 1, 1.80),
        Item(39, 'Y', 1, 1.80),
        Item(30, 'Pane', 1, 1.80),
        Item(35, 'X', 1, 1.80),
        Item(39, 'Y', 1, 1.80),
        Item(63, 'IPA Beer', 1, 15.00)
      ]),
      Order(3,DateTime.now(),[
        Item(1, 'Coca Cola', 5, 1.50),
        Item(5, 'Gruyère', 1, 4.70),
        Item(33, 'Brot 1kg', 1, 1.80),
        Item(62, 'Wine 1L', 3, 15.00)
      ])
    ];
  }

  static Order? fetchById(int orderId) {
    // NOTE: this will replaced by a proper API call
    List<Order> orders = Order.fetchAll();
    for (var i = 0; i < orders.length; i++) {
      if (orders[i].id == orderId) {
        return orders[i];
      }
    }
    return null;
  }
}

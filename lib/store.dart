
import 'package:flutter/material.dart';

// ======================================================
// PART MODEL
// ======================================================

class Part {
  final int id;

  String name;
  String category;
  String description;
  String vehicle;

  double price;
  int stock;

  Part(
      this.id,
      this.name,
      this.category,
      this.description,
      this.vehicle,
      this.price,
      this.stock,
      );
}

// ======================================================
// ORDER LINE MODEL
// ======================================================

class OrderLine {
  final String name;
  final double price;
  final int quantity;

  OrderLine(
      this.name,
      this.price,
      this.quantity,
      );

  double get total => price * quantity;
}

// ======================================================
// ORDER MODEL
// ======================================================

class Order {
  final int id;
  final String customer;
  final String phone;
  final String notes;
  final DateTime created;
  final List<OrderLine> lines;

  String status;

  Order(
      this.id,
      this.customer,
      this.phone,
      this.notes,
      this.created,
      this.lines,
      this.status,
      );

  double get total {
    return lines.fold<double>(
      0.0,
          (sum, line) => sum + line.total,
    );
  }
}

// ======================================================
// SHOP STATE MANAGEMENT
// ======================================================

class Shop extends ChangeNotifier {
  // SINGLETON INSTANCE
  static final Shop instance = Shop._();

  Shop._();

  // ====================================================
  // SAMPLE SPARE PARTS
  // ====================================================

  final List<Part> parts = [
    Part(
      1,
      'Brake Pads',
      'Brakes',
      'Front brake pad set',
      'Toyota Corolla',
      350.00,
      15,
    ),
    Part(
      2,
      'Oil Filter',
      'Filters',
      'Engine oil filter',
      'VW Polo',
      120.00,
      30,
    ),
    Part(
      3,
      'Car Battery',
      'Electrical',
      '12V battery',
      'Universal - check fit',
      1250.00,
      8,
    ),
    Part(
      4,
      'Spark Plugs',
      'Engine',
      'Set of four plugs',
      'Toyota Yaris',
      280.00,
      20,
    ),
  ];

  // ====================================================
  // ORDERS, CART AND CUSTOMERS
  // ====================================================

  final List<Order> orders = [];

  final Map<int, int> cart = {};

  // DEMO ONLY: Passwords are stored in memory.
  final Map<String, String> customers = {
    'customer@example.com': 'customer123',
  };

  String? email;

  bool admin = false;

  int _nextPart = 5;
  int _nextOrder = 1;

  // ====================================================
  // FIND PRODUCT BY ID
  // ====================================================

  Part? byId(int id) {
    for (final part in parts) {
      if (part.id == id) {
        return part;
      }
    }

    return null;
  }

  // ====================================================
  // CUSTOMER / ADMIN LOGIN
  // ====================================================

  bool login(String user, String password) {
    final username = user.trim().toLowerCase();

    // ADMINISTRATOR LOGIN
    if (username == 'admin@autoparts.local' &&
        password == 'admin123') {
      email = username;
      admin = true;
      cart.clear();

      notifyListeners();
      return true;
    }

    // CUSTOMER LOGIN
    if (customers.containsKey(username) &&
        customers[username] == password) {
      email = username;
      admin = false;
      cart.clear();

      notifyListeners();
      return true;
    }

    return false;
  }

  // ====================================================
  // CUSTOMER REGISTRATION
  // ====================================================

  String? register(String user, String password) {
    final username = user.trim().toLowerCase();

    if (username.isEmpty || !username.contains('@')) {
      return 'Enter a valid email address';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (customers.containsKey(username) ||
        username == 'admin@autoparts.local') {
      return 'Account already exists';
    }

    customers[username] = password;

    email = username;
    admin = false;
    cart.clear();

    notifyListeners();

    return null;
  }

  // ====================================================
  // LOGOUT
  // ====================================================

  void logout() {
    email = null;
    admin = false;

    cart.clear();

    notifyListeners();
  }

  // ====================================================
  // ADD PRODUCT TO CART
  // ====================================================

  void addToCart(Part part) {
    if (email == null || admin) return;

    final currentPart = byId(part.id);

    if (currentPart == null) return;

    final quantity = cart[part.id] ?? 0;

    if (currentPart.stock <= 0 ||
        quantity >= currentPart.stock) {
      return;
    }

    cart[part.id] = quantity + 1;

    notifyListeners();
  }

  // ====================================================
  // CHANGE CART QUANTITY
  // ====================================================

  void changeQty(int id, int delta) {
    final part = byId(id);

    if (part == null) {
      cart.remove(id);
      notifyListeners();
      return;
    }

    final currentQuantity = cart[id] ?? 0;
    final newQuantity = currentQuantity + delta;

    if (newQuantity <= 0) {
      cart.remove(id);
    } else if (newQuantity <= part.stock) {
      cart[id] = newQuantity;
    } else {
      return;
    }

    notifyListeners();
  }

  // ====================================================
  // TOTAL NUMBER OF CART ITEMS
  // ====================================================

  int get cartCount {
    return cart.values.fold<int>(
      0,
          (sum, quantity) => sum + quantity,
    );
  }

  // ====================================================
  // CART TOTAL
  // ====================================================

  double get cartTotal {
    return cart.entries.fold<double>(
      0.0,
          (sum, entry) {
        final part = byId(entry.key);

        if (part == null) return sum;

        return sum + (part.price * entry.value);
      },
    );
  }

  // ====================================================
  // CHECKOUT / PLACE ORDER
  // ====================================================

  String? checkout(String phone, String notes) {
    if (email == null || admin) {
      return 'Please log in as a customer';
    }

    if (cart.isEmpty) {
      return 'Your cart is empty';
    }

    final customerPhone = phone.trim();

    if (customerPhone.isEmpty) {
      return 'Please enter your phone number';
    }

    // CHECK STOCK BEFORE CREATING ORDER
    for (final entry in cart.entries) {
      final part = byId(entry.key);

      if (part == null ||
          entry.value <= 0 ||
          entry.value > part.stock) {
        return 'Insufficient stock for '
            '${part?.name ?? 'a part'}';
      }
    }

    final List<OrderLine> lines = [];

    // CREATE ORDER ITEMS AND REDUCE STOCK
    for (final entry in cart.entries) {
      final part = byId(entry.key)!;

      lines.add(
        OrderLine(
          part.name,
          part.price,
          entry.value,
        ),
      );

      part.stock -= entry.value;
    }

    // SAVE ORDER
    final order = Order(
      _nextOrder++,
      email!,
      customerPhone,
      notes.trim(),
      DateTime.now(),
      lines,
      'Pending',
    );

    orders.add(order);

    // CLEAR CART AFTER CHECKOUT
    cart.clear();

    notifyListeners();

    return null;
  }

  // ====================================================
  // ADD OR UPDATE SPARE PART
  // ====================================================

  void savePart({
    int? id,
    required String name,
    required String category,
    required String description,
    required String vehicle,
    required double price,
    required int stock,
  }) {
    if (name.trim().isEmpty ||
        category.trim().isEmpty ||
        !price.isFinite ||
        price <= 0 ||
        stock < 0) {
      throw ArgumentError('Invalid product information');
    }

    final oldPart = id == null ? null : byId(id);

    if (id != null && oldPart == null) {
      throw StateError('Product not found');
    }

    if (oldPart == null) {
      // ADD NEW PRODUCT
      parts.add(
        Part(
          _nextPart++,
          name.trim(),
          category.trim(),
          description.trim(),
          vehicle.trim(),
          price,
          stock,
        ),
      );
    } else {
      // UPDATE EXISTING PRODUCT
      oldPart.name = name.trim();
      oldPart.category = category.trim();
      oldPart.description = description.trim();
      oldPart.vehicle = vehicle.trim();
      oldPart.price = price;
      oldPart.stock = stock;

      // KEEP CART QUANTITY WITHIN NEW STOCK LIMIT
      final cartQuantity = cart[oldPart.id] ?? 0;

      if (cartQuantity > stock) {
        if (stock == 0) {
          cart.remove(oldPart.id);
        } else {
          cart[oldPart.id] = stock;
        }
      }
    }

    notifyListeners();
  }

  // ====================================================
  // DELETE SPARE PART
  // ====================================================

  void deletePart(int id) {
    parts.removeWhere(
          (part) => part.id == id,
    );

    cart.remove(id);

    notifyListeners();
  }

  // ====================================================
  // UPDATE ORDER STATUS
  // ====================================================

  void updateStatus(Order order, String status) {
    const allowedStatuses = [
      'Pending',
      'Confirmed',
      'Ready for collection',
      'Completed',
      'Cancelled',
    ];

    if (!allowedStatuses.contains(status)) return;

    if (!orders.contains(order)) return;

    order.status = status;

    notifyListeners();
  }
}

// ======================================================
// SOUTH AFRICAN RAND FORMAT
// ======================================================

String money(num amount) {
  return 'R ${amount.toStringAsFixed(2)}';
}

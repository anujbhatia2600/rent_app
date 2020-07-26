import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_app/providers/orders.dart';
import 'package:rent_app/providers/user.dart';
import 'package:rent_app/widgets/cart_tile.dart';
import 'package:rent_app/widgets/enter_details_form.dart';
import '../providers/cart.dart';

class OrderSummaryScreen extends StatefulWidget {
  static const routeName = 'order-summary';
  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Order Summary'),
        ),
        body: OrderSummaryBlock());
  }
}

class OrderSummaryBlock extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<OrderSummaryBlock> {
  final _form = GlobalKey<FormState>();
  var cart;
  var cartProduct;
  var _user;
  var _isLoading = false;

  Future<void> saveForm(User editedUser) async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Orders>(context, listen: false).updateUser(editedUser);
    await Provider.of<Orders>(context, listen: false)
        .addOrder(cartProduct, cart.totalAmount);
    setState(() {
      _isLoading = false;
    });
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Thank you. Your order has been confirmed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        child: Text('Go to Home'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .popAndPushNamed('/products-screen');
                        },
                      )
                    ],
                  ),
                ),
              ),
            ));
    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    cart = Provider.of<Cart>(context);
    cartProduct = cart.items.values.toList();
    _user = Provider.of<Orders>(context).user;
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : cartProduct.length > 0
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                            itemBuilder: (ctx, index) => CartTile(
                              cartProduct: cartProduct,
                              index: index,
                            ),
                            itemCount: cart.items.length,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 20),
                          width: double.infinity,
                          child: Text(
                            'Bill Total: ₹${cart.totalAmount}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: EnterDetailsForm(
                          saveForm: saveForm, form: _form, editedUser: _user),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
  }
}

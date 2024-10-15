// all 50 states
enum State {
  alabama,
  alaska,
  arizona,
  arkansas,
  california,
  colorado,
  connecticut,
  delaware,
  florida,
  georgia,
  hawaii,
  idaho,
  illinois,
  indiana,
  iowa,
  kansas,
  kentucky,
  louisiana,
  maine,
  maryland,
  massachusetts,
  michigan,
  minnesota,
  mississippi,
  missouri,
  montana,
  nebraska,
  nevada,
  newHampshire,
  newJersey,
  newMexico,
  newYork,
  northCarolina,
  northDakota,
  ohio,
  oklahoma,
  oregon,
  pennsylvania,
  rhodeIsland,
  southCarolina,
  southDakota,
  tennessee,
  texas,
  utah,
  vermont,
  virginia,
  washington,
  westVirginia,
  wisconsin,
  wyoming
}

class Payment {
  const Payment(
      {required this.cardNumber,
      required this.expirationMonth,
      required this.expirationYear,
      required this.cvc,
      required this.street,
      required this.city,
      required this.state,
      required this.zip});

  final int cardNumber;
  final int expirationMonth;
  final int expirationYear;
  final int cvc;
  final String street;
  final String city;
  final State state;
  final int zip;
}

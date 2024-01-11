class Action {
  int? stateNumber = null;
  String actionTitle = '';
  int? ruleNumber = null;

  Action.reduce(this.ruleNumber) {
    actionTitle = 'r($ruleNumber)';
  }
  Action.shift(this.stateNumber) {
    actionTitle = 's($stateNumber)';
  }

  Action.goto(this.stateNumber) {
    actionTitle = '$stateNumber';
  }

  Action.accept() {
    actionTitle = 'ACC';
  }

  @override
  String toString() {
    return actionTitle;
  }
}

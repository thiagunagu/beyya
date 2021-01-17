//Owner(email) and docID of ListInUse - will be same as signedInUser if he/she
// didn't join anyone's list
abstract class ListInUse {}

class ListInUseId implements ListInUse {
  final String ownerOfListInUse; //email
  final String docIdOfListInUse;
  ListInUseId({
    this.ownerOfListInUse,
    this.docIdOfListInUse,
  });
}

class ErrorFetchingListInUSe implements ListInUse {
  final String err;
  ErrorFetchingListInUSe({
    this.err,
  });
}

class LoadingListInUse implements ListInUse {
  const LoadingListInUse();
}

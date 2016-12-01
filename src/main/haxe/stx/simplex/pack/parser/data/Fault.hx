package stx.simplex.pack.Simplex.parser.data;

enum FaultKind{

}
enum Fault{
  /// an error code
  Code(e:FaultKind);
  /// an error code, and the next error in the parsing chain
  Node(node:FaultKind, next:Fault);
  /// an error code and the related input position
  Position(err:FaultKind, position:Position);
  /// an error code, the related input position, and the next error in the parsing chain
  NodePosition(e:FaultKind, position:Position, next:Fault);
}
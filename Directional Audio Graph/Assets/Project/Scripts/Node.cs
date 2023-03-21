using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Node : MonoBehaviour
{
    static Node highlightedNode;
    public List<Node> connections;

    private void OnDrawGizmos() {
        foreach (var c in connections)
        {
            if (c) Gizmos.DrawLine(transform.position, c.transform.position);
        }
        if (highlightedNode == this) Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, 1);
    }

    public static void Highlight(Node nodeToHighlight)
    {
        highlightedNode = nodeToHighlight;
    }
}

//// 
//// Taken from https://forum.unity.com/threads/freebie-a-c-adjacency-list-implementation.41873/
////


using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

[Serializable]
public class AdjacencyList<K> : IEnumerable
{
    private List<List<K>> _vertexList = new List<List<K>>();
    private Dictionary<K, List<K>> _vertexDict = new Dictionary<K, List<K>>();

    // Define the indexer to allow client code to use [] notation.
    public List<K> this[int i]
    {
        get { return _vertexList[i]; }
        private set { _vertexList[i] = value; }
    }

    // Implemented getter and setter for Length to use in for loops
    public int Length {get {return _vertexList.Count;} private set{}}
 
    public AdjacencyList(K rootVertexKey)
    {
        AddVertex(rootVertexKey);
    }
   
    private List<K> AddVertex(K key)
    {
        List<K> vertex = new List<K>();
        vertex.Add(key);
        _vertexList.Add(vertex);
        _vertexDict.Add(key, vertex);
       
        return vertex;
    }
   
    public void AddEdge(K startKey, K endKey)
    {
        List<K> startVertex = _vertexDict.ContainsKey(startKey) ? _vertexDict[startKey] : null;
        List<K> endVertex = _vertexDict.ContainsKey(endKey) ? _vertexDict[endKey] : null;
 
        if (startVertex == null)
            throw new ArgumentException("Cannot create edge from a non-existent start vertex.");
 
        if (endVertex == null)
            endVertex = AddVertex(endKey);
 
        startVertex.Add(endKey);
        endVertex.Add(startKey);
    }
   
    public void RemoveVertex(K key)
    {
        List<K> vertex = _vertexDict[key];
       
        //First remove the edges / adjacency entries
        int vertexNumAdjacent = vertex.Count;
        for (int i = 0; i < vertexNumAdjacent; i++)
        {  
            K neighbourVertexKey = vertex[i];
            RemoveEdge(key, neighbourVertexKey);
        }
 
        //Lastly remove the vertex / adj. list
        _vertexList.Remove(vertex);
        _vertexDict.Remove(key);
    }
   
    public void RemoveEdge(K startKey, K endKey)
    {
        ((List<K>)_vertexDict[startKey]).Remove(endKey);
        ((List<K>)_vertexDict[endKey]).Remove(startKey);
    }
   
    public bool Contains(K key)
    {
        return _vertexDict.ContainsKey(key);
    }
   
    public int VertexDegree(K key)
    {
        return _vertexDict[key].Count;
    }

    public List<K> GetEdgesOfKey(K key)
    {
        return _vertexDict[key].GetRange(1, _vertexDict[key].Count - 1);
    }

    // Implemented to make use of foeach for this class
    IEnumerator IEnumerable.GetEnumerator() {
        return (IEnumerator)_vertexList;
    } 

    // Implemented to print nodes in console
    public void LogList()
    {
        foreach (var v in _vertexList)
        {
            foreach (var k in v)
            {
                Debug.Log(k.ToString());
            }
            Debug.Log("\n");
        }
    }
}
 
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "Readme", menuName = "ScriptableObjects/Readme", order = 5 )]
public class Readme : ScriptableObject
{
	public Texture2D icon;
	public string title;
	public Section[] sections;
	public bool loadedLayout;
	
	[System.Serializable]
	public class Section {
		public string heading, text, linkText, url;
	}
}

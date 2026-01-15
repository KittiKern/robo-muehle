== State Encoding
Zur Vorbereitung der Spieldaten werden die Positionen der Spielsteine mittels One-Hot-Kodierung repräsentiert. Ergänzend zu den positionsbezogenen Informationen werden globale Merkmale (Features) in den Zustandsvektor integriert. Diese umfassen die aktuelle Spielphase („Setzen“, „Bewegen“, „Springen“), welche ebenfalls One-Hot-kodiert wird, die Anzahl der noch zu platzierenden Spielsteine in normalisierter Form sowie binäre Indikatoren dafür, ob in dem aktuellen Zug ein Spielstein entfernt werden muss und ob sich das Spiel in der Springen-Phase befindet.

Die Kodierung der Spielphase erfolgt bewusst redundant, um dem Modell explizit zu vermitteln, dass sich die Bewegungsregeln ändern, sobald ein Spieler nur noch drei Spielsteine auf dem Spielfeld besitzt. Auf diese Weise ist der Spielzustand stets an zwei Eingaben gekoppelt: Zum einen an die Information, ob noch Spielsteine zu platzieren sind (Platzieren-Phase), und zum anderen an die explizite Zustandskodierung der aktuellen Spielphase. Daraus ergeben sich zwei separate Eingaberepräsentationen: eine tensorförmige Repräsentation der Dimension (3, 24) zur Abbildung der Spielsteinpositionen sowie ein Vektor der Länge 11 zur Beschreibung der globalen Zustandsmerkmale.

Der Ausgaberaum des Modells wird als eindimensionales Array der Länge 24 × 25 modelliert. Jede mögliche Kombination aus Quell- und Zielposition wird dabei durch eine eigene Wahrscheinlichkeit repräsentiert. Die indecies 0 bis 23 entsprechen den tatsächlichen Positionen auf dem Spielbrett, während der Index 24 als Platzhalter verwendet wird, sofern keine Quell- oder Zielposition existiert, etwa beim Setzen oder Entfernen eines Spielsteins. Der zugehörige Index im Ausgabearray ergibt sich gemäß ``` index = source × 24 + target ``` wobei source die Ausgangsposition und target die Zielposition bezeichnet.

== Neural Network Architecture
Die kodierten Eingabeinformationen werden jeweils einem eigenen Input-Layer zugeführt. Die Positionsinformationen der Spielsteine werden zuvor geflattet, da es sich bei der verwendeten Architektur um ein einfaches Feed-Forward-Netzwerk handelt, welches keine inhärente Unterstützung für strukturierte oder sequenzielle Daten bietet.

Nach der Verarbeitung in den jeweiligen Input-Layern werden die resultierenden Ausgaben konkateniert und anschließend durch zwei Hidden-Layer weiterverarbeitet. Beide Hidden-Layer bestehen aus jeweils 256 Neuronen. Da keine fundierte Vorabkenntnisse hinsichtlich der optimalen Dimensionalität der Feature-Repräsentationen vorlag, wurde die Anzahl der Neuronen heuristisch gewählt. Dabei wurde konsequent ein Vielfaches von zwei verwendet und schrittweise skaliert, um eine ausreichende Modellkapazität sicherzustellen.

Im finalen Verarbeitungsschritt wird ein Policy-Head definiert, der die relevanten Logits ausgibt. Diese Logits können anschließend vom Action-Mapper interpretiert werden, um konkrete Aktionen abzuleiten. Zusätzlich wurde für Trainingszwecke ein separater Value-Head implementiert. Dieser dient der Approximation des Zustandswertes beziehungsweise der Advantage des aktuellen Spielzustands. Entsprechend soll der Ausgabewert nahe bei 1 liegen, wenn sich das Modell in einer nahezu gewinnenden Situation befindet, und nahe bei −1, wenn ein Verlust unmittelbar bevorsteht.

Der Value-Head reduziert die Repräsentation zunächst über einen weiteren Hidden-Layer mit 128 Neuronen und projiziert diese anschließend auf eine skalare Ausgabe. Als Aktivierungsfunktion wird hierbei die hyperbolische Tangensfunktion (tanh) verwendet, um den Wertebereich explizit auf das Intervall [−1, 1] zu beschränken. Für alle übrigen Layer kommt die ReLU-Aktivierungsfunktion zum Einsatz.
#figure(
  image("ai.png", width: 100%),
  caption: [Model Architektur],
) <model_architecture>

=== Mögliche Model Architektur verbesserungen
Derzeit wird das Modell als einfaches Feedforward-Netzwerk implementiert. Da das Spiel Mühle jedoch als Graph betrachtet werden kann und die Erfassung graphbasierter Relationen potenziell zur besseren Modellierung der Spielstruktur beiträgt, könnte der Einsatz eines Graph Neural Networks (GNN) vorteilhaft sein.

=== Feed Forward Neural Network
Ein Feedforward-neuronales Netzwerk ist ein künstliches neuronales Netzwerk, bei dem die Informationsverarbeitung strikt gerichtet erfolgt. Die Eingabewerte werden schichtweise mit Gewichtungsfaktoren multipliziert und zu Ausgabewerten transformiert. Dieses Modell steht im Gegensatz zu rekurrenten neuronalen Netzwerken, bei denen zyklische Verbindungen existieren, durch die Informationen aus späteren Verarbeitungsstufen wieder auf frühere Schichten zurückgeführt werden können.

Die feedforward-Struktur ist eine grundlegende Voraussetzung für die Anwendung des Backpropagation-Verfahrens und eine der ersten Strukturen die implementiert wurde.
@wikipedia_ffnn

=== Multi-layer perceptron
In der Deep-Learning-Forschung bezeichnet ein Multilayer-Perzeptron (MLP) eine Form moderner vorwärtsgerichteter neuronaler Netze (wie eben erklärt), die aus vollständig miteinander verbundenen Neuronen besteht, welche in mehreren Schichten organisiert sind und nichtlineare Aktivierungsfunktionen verwenden. Charakteristisch für MLPs ist ihre Fähigkeit, auch nicht linear separierbare Daten zu modellieren und zu klassifizieren.

Multilayer-Perzeptrons bilden eine grundlegende Architektur des Deep Learning und finden Anwendung in einer Vielzahl unterschiedlicher Domänen. @wikipedia_multilayer

=== Graph Neural Networks(GNN)
Graph Neural Networks (GNNs) sind eine spezialisierte Klasse künstlicher neuronaler Netze, die für Aufgaben entwickelt wurden, bei denen die Eingabedaten in Form von Graphen vorliegen.
@wikipedia_gnn

== Training
=== reinforcement learning
Reinforcement Learning ist ein Teilgebiet des maschinellen Lernens und der optimalen Regelung, das sich mit der Frage befasst, wie ein intelligenter Agent in einer dynamischen Umgebung Handlungen auswählt, um ein langfristiges Belohnungssignal zu maximieren. Im Gegensatz zum supervised und unsupervised learning, die auf der Analyse gelabelter beziehungsweise ungelabelter Daten basieren, erfolgt das Lernen beim Reinforcement Learning durch direkte Interaktion des Agenten mit seiner Umgebung. Dabei erhält der Agent Rückmeldungen in Form von Belohnungen oder Strafen, anhand derer er schrittweise eine optimale Handlungsstrategie (Policy) erlernt.
@wikipedia_reinforcement

=== Self-play
Self-play ist ein Paradigma, bei dem ein Agent gegen sich selbst spielt, um seine Strategie zu verbessern. Dies ermöglicht es uns, unsere Mühle-KI zu trainieren, ohne einen Datensatz zu verwenden oder jeglichen Eingriff in das Training zu haben.
@wikipedia_self_play

=== Actor-Critic
Der Actor-Critic-Algorithmus stellt eine Klasse von Reinforcement-Learning-Methoden dar, die zwei zentrale Komponenten kombiniert: den Actor, der Aktionen auswählt, und den Critic, der diese Entscheidungen bewertet. Durch diese duale Struktur wird das Lernen des Agenten effizienter, da Entscheidungsfindung und Rückmeldung in einem ausgewogenen Verhältnis erfolgen. Während der Actor lernt, wie Entscheidungen getroffen werden, prüft der Critic deren Qualität. Dies ermöglicht es dem Agenten, neue Aktionen zu explorieren und gleichzeitig auf bereits erlernten Erfahrungen aufzubauen, wodurch der Lernprozess stabiler und effektiver wird.
Die Policy entspricht dem Actor, der die Aktionen auswählt, während value den Critic darstellt, der die Qualität dieser Aktionen bewertet. @actor_critic

=== GAE

=== Entropy Regularization
Entropy-Regularisierung ist eine Methode zur Regularisierung der Modelloutputs, bei der der Verlustfunktion ein zusätzlicher Term hinzugefügt wird, der das Modell dazu anregt, Ausgaben mit höherer Entropie zu erzeugen. Entropie, im Sinne der Informationstheorie, quantifiziert die Unsicherheit oder Zufälligkeit einer Wahrscheinlichkeitsverteilung. Durch die Maximierung der Entropie der Ausgabeverteilung wird das Modell dazu motiviert, vielfältigere und weniger übermäßig selbstsichere Vorhersagen zu treffen.@entropy_reg

=== Reward Shaping
Reward Shaping ist eine Methode, bei der zusätzliche Belohnungen eingeführt werden, um das Lernen eines Agenten zu beschleunigen. Ziel ist es, den Agenten Schritt für Schritt in die richtige Richtung zu lenken, insbesondere in Situationen, in denen die ursprüngliche Belohnung sehr selten oder spärlich auftritt.
@reward_shaping In unserem Fall wird der Agent so gesteuert, dass der erzielte Spielvorteil und das Schließen von Mühlen durch positive Belohnungen gefördert werden, während verbotene Züge negative Rückmeldungen erhalten.

=== Gradient Clipping
Gradient Clipping bezeichnet eine Technik, die darauf abzielt, die Stabilität des Trainings von neuronalen Netzwerken zu gewährleisten, indem die Größe der Gradienten begrenzt wird. Während des Backpropagation Verfahrens werden Gradienten berechnet, die die Richtung und Stärke der Gewichtsaktualisierungen im Netzwerk bestimmen. Treten jedoch übermäßig große Gradienten auf, was als „Gradient Exploding“ bezeichnet wird, können die resultierenden Gewichtsänderungen numerische Instabilitäten hervorrufen, wie beispielsweise das Auftreten von NaN-Werten oder Overflow-Fehlern. Gradient Clipping löst dieses Problem, indem die Norm der Gradienten auf einen vorab definierten Maximalwert beschränkt wird. Auf diese Weise wird sichergestellt, dass die Aktualisierungen der Modellparameter kontrolliert bleiben, ohne die Lernfähigkeit des Netzwerks wesentlich einzuschränken, und trägt somit maßgeblich zu einem stabilen und effizienten Trainingsprozess bei. @grad_clip

=== Temperature Scaling
Temperature Scaling wird eingesetzt, um die vom Policy-Network ausgegebenen Wahrscheinlichkeiten zu kalibrieren. Dabei wird ein lernbarer Temperaturparameter T auf die Softmax-Ausgaben angewendet, wodurch übermäßig selbstsichere Wahrscheinlichkeiten abgeschwächt und Unsicherheiten realistischer dargestellt werden. In dem Spiel Mühle verhindert dies, dass der Agent falsche Züge mit zu hoher Sicherheit bevorzugt, fördert die Exploration alternativer Strategien und stabilisiert das Training, ohne die tatsächlichen Aktionsentscheidungen zu verändern. @temp_scale

=== ε-Greedy Exploration
Der ε-Greedy Algorithmus ist eine Strategie, mit der der Agent Handlungen auswählt, um eine Balance zwischen Exploration(das Ausprobieren neuer oder seltener gewählter Handlungen) und Exploitation (das Ausnutzen bereits bekannter, erfolgversprechender Handlungen) zu erreichen. Mit einer Wahrscheinlichkeit von ε wählt der Agent eine zufällige Handlung (Exploration), während er mit einer Wahrscheinlichkeit von 1−ε diejenige Handlung auswählt, deren geschätzter Aktionswert am höchsten ist (Exploitation). Auf diese Weise kann der Agent sowohl neue Erkenntnisse gewinnen als auch bekannte Belohnungspotenziale effizient nutzen. @e_greedy

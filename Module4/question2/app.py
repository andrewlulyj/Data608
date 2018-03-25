import dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd 
import numpy as np
import plotly.graph_objs as go

url = "https://raw.githubusercontent.com/charleyferrari/CUNY_DATA_608/master/module4/Data/riverkeeper_data_2013.csv"
data = pd.read_csv(url)

data_list = np.unique(data['Site'])


for  i in range(0,len(data['EnteroCount'])):
    if ">" in data['EnteroCount'][i]:
        data['EnteroCount'][i] = int(data['EnteroCount'][i][1:])+1
    elif "<" in data['EnteroCount'][i]:
        data['EnteroCount'][i] = int(data['EnteroCount'][i][1:])-1
flag=['recommand' if int(i) < 110 else 'not recommand' for i in data['EnteroCount']]
data['flag'] = flag
data['EnteroCount'] = data['EnteroCount'].astype(int) 

app = dash.Dash()
app.css.append_css({'external_url': 'https://cdn.rawgit.com/plotly/dash-app-stylesheets/2d266c578d2a6e8850ebce48fdb52759b2aef506/stylesheet-oil-and-gas.css'}) 
app.layout = html.Div(children=[
    html.H1(children='Exploratory Analysis'),
    html.Div([
    html.Div([
    html.Div(children='''
        Select A Site.
    '''),
    html.Div([
            dcc.Dropdown(
                id='s',
                options=[{'label': i, 'value': i} for i in data_list],
                value='Hudson above Mohawk River'
               
            )]),
    dcc.Graph(
        id='graph'
    )], className='six columns'),
    html.Div([
    html.Div(children='''
        Select A Site.
    '''),
    html.Div([
            dcc.Dropdown(
                id='s2',
                options=[{'label': i, 'value': i} for i in data_list],
                value='Hudson above Mohawk River'
               
            )]),
    dcc.Graph(
        id='graph2'
    )], className='six columns')],
    className='row' ),
    html.Div(children='''
                   The analysis is based on single sample entero count since we don't have geometric mean and
        only total samples available. Entero count is adjusted by 1 if the value has > or < sign.
    ''',className='row'),
     
])

@app.callback(
    dash.dependencies.Output('graph', 'figure'),
    [dash.dependencies.Input('s', 'value')])
def update_graph(s_value):
    filter_data=data[data['flag']=='recommand'] 
    filter_data=filter_data[filter_data['Site']==s_value]
    filter_data=filter_data.sort_values(by=['Date'])
    return{
           'data': [go.Scatter(
            x=filter_data['FourDayRainTotal'],
            y=filter_data['EnteroCount'],
            text=filter_data['flag'],
            mode='markers',
            marker={
                'size': 15,
                'opacity': 0.5,
                'line': {'width': 0.5, 'color': 'white'}
            }
        )],
        'layout': go.Layout(
            title = s_value,    
            xaxis={
                'title': 'Four Day Rain Total',
                
            },
            yaxis={
                'title': 'Entero Count',
                
            },
            margin={'l': 40, 'b': 40, 't': 40, 'r': 0},
            hovermode='closest'
        )
            }

@app.callback(
    dash.dependencies.Output('graph2', 'figure'),
    [dash.dependencies.Input('s2', 'value')])
def update_graph2(s_value):
    filter_data2=data[data['flag']=='recommand'] 
    filter_data2=filter_data2[filter_data2['Site']==s_value]
    filter_data2=filter_data2.sort_values(by=['Date'])
    return{
           'data': [go.Scatter(
            x=filter_data2['FourDayRainTotal'],
            y=filter_data2['EnteroCount'],
            text=filter_data2['flag'],
            mode='markers',
            marker={
                'size': 15,
                'opacity': 0.5,
                'line': {'width': 0.5, 'color': 'white'}
            }
        )],
        'layout': go.Layout(
            title = s_value,    
            xaxis={
                'title': 'Four Day Rain Total',
                
            },
            yaxis={
                'title': 'Entero Count',
                
            },
            margin={'l': 40, 'b': 40, 't': 40, 'r': 0},
            hovermode='closest'
        )
            }

if __name__ == '__main__':
    app.run_server(debug=False)
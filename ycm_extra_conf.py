

def Settings( **kwargs ):
  if kwargs[ 'language' ] == 'rust':
    return {
        'ls': {
            'rust': {
                'all_targets': False,
                'wait_to_build': 1500,
            }
        }
    }
